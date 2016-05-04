# coding: utf-8
require 'timeout'
require 'gogokit'
require 'benchmark'

module ViagogoDataToHoishow
  module Service
    extend ViagogoLogger
    extend self

    def data_to_hoishow
      Benchmark.bm do |b|
        #创建star, concert, city, stadium, show, event, area等数据
        b.report("data_transform:"){data_transform}
        #用sidekiq更新viagogo的所有event的areas的数据
        b.report("update_events_data:"){update_events_data}
        b.report("update_star_avatar:"){update_star_avatar}
        b.report("update_show_poster:"){update_show_poster}
        #用sidekiq更新所有event场馆图
        b.report("update_events_stadium_map:"){update_events_stadium_map}
      end
    end

    def data_transform
      client = get_client
      rate = get_exchange_rate
      if client.present? && rate.present?

        default_description = "<span style=\"line-height: 1.42857;\">1. 本场比赛为海外赛事，系统需要确定库存和价格，购票支付成功后 24 小时内将会提供出票状态，出票成功将会以短信形式通知；如出票失败，订单金额将会原路退还；</span><p></p><p><span style=\"line-height: 1.42857;\">2. 本场比赛出票形式为电子票，不支持快递配送业务。成功购票后，订票手机号将会收到电子门票的下载地址，届时凭自助打印纸质票进场；</span></p><p><span style=\"line-height: 1.42857;\">3. 海外体育赛事日期和时间为当地时间，请购票前核对时间信息；</span></p><p><span style=\"line-height: 1.42857;\">4. 赛事门票具有唯一性、时效性等特殊属性，如非比赛变更、取消、票品错误原因外，不提供退还票品服务，购票时请务必仔细核对活动信息；</span></p><p>最终解释权归 <b>单车娱乐</b> 所有</p><p></p><p></p><p></p><p></p><p></p>"

        mlb_url = "https://api.viagogo.net/v2/categories/4953/children"

        res_json = get_url_json(mlb_url, client)
        if res_json.nil? || res_json["total_items"] > 30
          viagogo_logger.info "total_items数量不正确"
          return
        end

        teams = res_json["_embedded"]["items"]

        teams.each do |team|
          event_url = "https://api.viagogo.net/v2/categories/#{team["id"].to_s}/events?only_with_tickets=true&page_size=199"

          events_json = get_url_json(event_url, client)
          if events_json.nil? || events_json["total_items"] == 0
            next
          end

          events = events_json["_embedded"]["items"]

          events.each do |event|
            Star.transaction do
              unless star = Star.where(event_path: team["id"].to_s).first
                star = Star.create(name: team["name"], event_path: team["id"].to_s)
              end
              concert_name = event["name"]
              concert = Concert.where(name: concert_name).first_or_create(is_show: "auto_hide", status: "finished")
              star.hoi_concert(concert)

              venue_json = event["_embedded"]["venue"]
              city_name = venue_json["city"]
              city = City.where(source_name: city_name).first_or_create(name: city_name, source: 4)
              stadium_name = venue_json["name"]
              stadium = Stadium.where(source_name: stadium_name, city_id: city.id).first_or_create(name: stadium_name, longitude: venue_json["longitude"], latitude: venue_json["latitude"], source: 4)

              show = Show.where(source_name: concert_name, stadium_id: stadium.id).first_or_create(name: concert_name, concert_id: concert.id, city_id: city.id, source: 4, ticket_type: 0, mode: 1, status: 0, seat_type: 1, description: default_description, show_type: "MLB")

              #show的名字中文化
              if show.name == concert_name
                team_names = concert_name.split(" vs. ")
                if team_names.count == 2
                  translated_name = concert_name.gsub(team_names[0], MLBSetting[team_names[0]]).gsub(team_names[1], MLBSetting[team_names[1]])
                  show.update(name: translated_name)
                end
              end

              #时间数据格式"2016-04-29T13:20:00-05:00"
              show_time = DateTime.strptime(event["start_date"], '%Y-%m-%dT%H:%M') - 8.hours

              event = Event.where(ticket_path: event["id"].to_s).first_or_create(show_time: show_time, show_id: show.id)
              event.update(show_time: show_time)
            end
          end#-------endof star-transaction
        end
      else
        return
      end
    end

    def update_events_data
      events = Event.where("ticket_path is not null and is_display is true")
      events.each{|event| UpdateViagogoEventWorker.perform_async(event.id)} if events.present?
    end

    #返回success变量来区别是否更新数据成功
    def update_event_data_with_api(event_id)
      success = false
      client = get_client
      rate = get_exchange_rate
      event = Event.find(event_id)
      show = event.show
      if client.present? && rate.present? && show.present? && event.present?
        ticket_json = get_events_data(event.ticket_path, client)

        if ticket_json.present? && ticket_json["total_items"] > 0
          success = true
          ticket_items = ticket_json["_embedded"]["items"]
          e_ticket_items = ticket_items.select{|i| i["_embedded"]["ticket_type"]["type"].include?("ETicket")}
          group_by_section_ticket_hash = e_ticket_items.group_by{|i| i["seating"]["section"]}

          source_area_ids = event.areas.pluck(:id)
          updated_area_ids = []

          group_by_section_ticket_hash.each do |name_info_hash|
            area_name = name_info_hash[0]
            ticket_info_array = name_info_hash[1]
            next if ticket_info_array.blank? || area_name.blank?

            seats_count = ticket_info_array.inject(0){|sum, hash| sum + hash["number_of_tickets"]}
            price_array = ticket_info_array.map do |i|
              ticket_price = (i["estimated_ticket_price"].present? ? i["estimated_ticket_price"]["amount"] : 0)
              booking_fee = (i["estimated_booking_fee"].present? ? i["estimated_booking_fee"]["amount"] : 0)
              shipping = (i["estimated_shipping"].present? ? i["estimated_shipping"]["amount"] : 0)
              vat = (i["estimated_vat"].present? ? i["estimated_vat"]["amount"] : 0)
              ticket_price + ( ( booking_fee + shipping + vat ) / i["number_of_tickets"] ).round(2)
            end.compact.sort
            #价格为(单价加上预约费)X汇率
            max_price = ( price_array.last * rate ).to_i + 200
            price_range = "#{( price_array.first * rate ).to_i + 200} - #{max_price}"

            #update_area_data
            area_id = update_area_logic(area_name, show, event, max_price, price_range, seats_count)
            if area_id.present?
              updated_area_ids << area_id
            else
              viagogo_logger.info "创建#{area_name}失败,show_id为#{show.id},event_id为#{event.id}"
            end
          end

          #隐藏不存在的区
          not_exist_ids = source_area_ids - updated_area_ids
          Area.where("id in (?)", not_exist_ids).update_all(is_exist: false)
        end
      end
      event.reload
      event.update(is_display: false) if event.areas.blank?
      success
    end

    def update_area_logic(area_name, show, event, max_price, price_range, seats_count)
      if area_name.present? && show.present? && event.present? && max_price.present? && price_range.present?
        Area.transaction do
          area = Area.where(name: area_name, event_id: event.id).first_or_create(seats_count: 0, left_seats: 0, source: 4)
          if area.present?
            relation = show.show_area_relations.where(area_id: area.id).first_or_create(seats_count: 0, left_seats: 0)
            if relation.present?
              old_seats_count = relation.seats_count
              old_seats_count ||= 0
              #新建的区
              if old_seats_count == 0 && seats_count > 0
                left_seats = seats_count
                seats_count.times { show.seats.where(area_id: area.id).create(status:Ticket::seat_types[:avaliable], price: max_price) }
              else
                #旧有的区
                #减少了座位
                if old_seats_count > seats_count
                  rest_tickets = old_seats_count - seats_count
                  left_seats = relation.left_seats - rest_tickets
                  show.seats.where('area_id = ? and order_id is null', area.id).limit(rest_tickets).destroy_all
                  #增加了座位
                elsif old_seats_count < seats_count
                  rest_tickets = seats_count - old_seats_count
                  left_seats = relation.left_seats + rest_tickets
                  rest_tickets.times { show.seats.where(area_id: area.id).create(status:Ticket::seat_types[:avaliable], price: max_price)  }
                  #座位数不变
                else
                  left_seats = relation.left_seats
                end
              end
              area.update(stadium_id: show.stadium.id, seats_count: seats_count, left_seats: left_seats, is_exist: true)
              relation.update(price: max_price, price_range: price_range, seats_count: seats_count, left_seats: left_seats)
              area.tickets.update_all(price: max_price)
            end
            return area.id
          else
            return nil
          end
        end#-----endof-area_transation
      end
    end

    def update_star_avatar
      logo_json = JSON.parse(File.open("./public/mlb_logos.json","r").readline)
      stars = Star.where("event_path is not null and avatar is null")
      if stars.present? && logo_json.present?
        stars.each do |star|
          url = logo_json[star.name]
          update_subject_url(star, url)
        end
      end
    end

    def update_show_poster
      logo_json = JSON.parse(File.open("./public/mlb_logos.json","r").readline)
      shows = Show.where("source = 4 and poster is null")
      if shows.present? && logo_json.present?
        shows.each do |show|
          stars = show.stars
          if ( stars.count == 2 )
            #确定主场队伍
            if show.name.start_with?(stars[0].name)
              first_star = stars.first
              second_star = stars.last
            else
              first_star = stars.last
              second_star = stars.first
            end

            bg_url = logo_json["mlbbg"]

            if first_star.avatar && second_star.avatar
              begin
                if Rails.env.production? || Rails.env.staging?
                  first_img = MiniMagick::Image.open(first_star.avatar.url)
                  second_img = MiniMagick::Image.open(second_star.avatar.url)
                else
                  first_img = MiniMagick::Image.open( first_star.avatar.current_path )
                  second_img = MiniMagick::Image.open( second_star.avatar.current_path )
                end
                bg_img = MiniMagick::Image.open(bg_url)
              rescue Exception => e
                viagogo_logger.info "打开图片出错，#{e}"
                next
              end
              res = combine_img(bg_img, first_img, "+140+180")
              res = combine_img(res, second_img, "+780+180")
              show.poster = res
              show.save
            end
          end
        end
      end
    end

    def combine_img(bg_img, over_img, position)
      bg_img.composite(over_img) do |c|
        c.compose "Over"
        c.geometry position
      end
    end

    def update_events_stadium_map
      events = Event.where("ticket_path is not null and stadium_map is null and is_display is true")
      events.each{|event| UpdateViagogoStadiumMapWorker.perform_async(event.id)} if events.present?
    end

    def update_event_stadium_map_with_api(event_id)
      client = get_client
      event = Event.find(event_id)
      if client.present? && event.present?
        event_json = get_url_json("https://api.viagogo.net/v2/events/#{event.ticket_path}/map", client)
        if event_json.present?
          return if event_json["_links"].blank? || event_json["_links"]["venuemap:gif"].blank?
          map_url = event_json["_links"]["venuemap:gif"]["href"]
          if map_url.present?
            map_url = "#{map_url[0..-4]}png"
          else
            return
          end
          update_subject_url(event, map_url)
        end
      end
    end

    def update_subject_url(subject, url)
      if subject && url
        subject_class = subject.class.name

        3.times do
          begin
            temp = 
              Timeout::timeout(5) do
                case subject_class
                when "Star"
                  #删除upyun上的旧数据
                  if subject.avatar.present?
                    subject.remove_avatar!
                  end
                  subject.remote_avatar_url = url  
                when "Show"
                  if subject.poster.present?
                    subject.remove_poster!
                  end
                  subject.remote_poster_url = url  
                when "Event"
                  if subject.stadium_map.present?
                    subject.remove_stadium_map!
                  end
                  subject.remote_stadium_map_url = url  
                end
                subject.save
              end
            if temp
              viagogo_logger.info "更新#{subject_class}_id: #{subject.id}成功"
              break
            else
              viagogo_logger.info "#{subject_class}_id: #{subject.id} timeout, 即将重试"
              next
            end
          rescue Exception => e
            viagogo_logger.info "#{subject_class}_id: #{subject.id} exception: #{e}, 即将重试"
            next
          end
        end
      end
    end

    def get_url_json(url, client)
      3.times do
        begin
          res = JSON.parse(client.get(url).body)
          if res.present?
            return res
          else
            next
          end
        rescue Exception => e
          viagogo_logger.info "访问#{url}失败,即将重试"
          next
        end
      end
      nil
    end

    def get_events_data(viagogo_event_id_string, client)
      3.times do
        begin
          ticket_json = get_url_json("https://api.viagogo.net/v2/events/#{viagogo_event_id_string}/listings?page_size=999", client)
          if ticket_json.present?
            return ticket_json
          else
            next
          end
        rescue Exception => e
          viagogo_logger.info "获取ticket数据失败, viagogo_event_id_string为#{viagogo_event_id_string} ,即将重试"
          next
        end
      end
      nil
    end

    def get_client
      client = GogoKit::Client.new do |config|
        config.client_id = ViagogoSetting["client_id"]
        config.client_secret = ViagogoSetting["client_secret"]
      end

      access_token = Rails.cache.read("viagogo_access_token")

      if access_token.nil?
        3.times do
          begin
            token = client.get_client_access_token
            if token.present?
              access_token = token.access_token
              Rails.cache.write("viagogo_access_token", access_token, expires_in: 1.day)
              break
            else
              next
            end
          rescue Exception => e
            viagogo_logger.info "获取access_token失败,即将重试"
            next
          end
        end
        return nil if access_token.nil?
      end

      client.access_token = access_token
      client
    end

    def get_exchange_rate
      rate = Rails.cache.read("viagogo_rate")
      return rate if rate.present?

      url = "http://api.fixer.io/latest?base=USD"
      3.times do
        begin
          res = Timeout::timeout(5) { RestClient.get url } rescue nil
          if res.present?
            res = JSON.parse res
            Rails.cache.write("viagogo_rate", res["rates"]["CNY"], expires_in: 1.day)
            return res["rates"]["CNY"]
          else
            next
          end
        rescue Exception => e
          viagogo_logger.info "获取汇率失败，即将重试"
          next
        end
      end
      nil
    end

    def data_clear
      ["Star", "Concert", "City", "Stadium", "Show", "Event", "Area", "ShowAreaRelation"].each{ |x| Object::const_get(x).delete_all }
    end

  end
end
