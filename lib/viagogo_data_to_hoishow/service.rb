# coding: utf-8
require 'timeout'

module ViagogoDataToHoishow
  module Service
    extend ViagogoLogger
    extend self

    VIAGOGO_URL = "http://www.viagogo.com"
    SERVICE_FEE = 1.3

    def data_transform
      client = SSDB::Client.new.connect
      if client.connected?

        event_path_array = client.hgetall("viagogo_hot_events", :list).map{|x| JSON.parse x}.flatten

        begin
          event_path_array.each do |event_path|
            Star.transaction do

              temp_data = client.hget("viagogo_events_info", event_path)
              if temp_data
                event_info_array = JSON.parse temp_data
              else
                next
              end

              if event_info_array.present?
                star_name = event_path.split("/").last[0..-9]
                star = Star.where(name: star_name, event_path: event_path).first
                if star
                  concert = Concert.where(name: "#{star.id}(自动生成)").first
                  next unless concert
                else
                  star = Star.create(name: star_name, event_path: event_path)
                  concert = Concert.create(name: "#{star.id}(自动生成)", is_show: "auto_hide", status: "finished")
                end
                star.hoi_concert(concert)
              else
                next
              end

              #格式为{"stadium_name" => [{}...],...}
              #一个stadium为一个show,不同日期为不同场次
              event_info_group_by_stadium_hash = event_info_array.group_by{|x| x["VenueName"]}
              event_info_group_by_stadium_hash.each do |info_hash|
                stadium_name = info_hash[0]
                temp_data = info_hash[1].select{|x| x["VenueCity"].present?}.first
                if temp_data
                  city_name = temp_data["VenueCity"]
                else
                  next
                end
                city = City.where(name: city_name).first_or_create
                stadium = Stadium.where(name: stadium_name, city_id: city.id).first_or_create
                show = Show.where(name: (star_name + " In " + stadium_name), concert_id: concert.id, city_id: city.id, stadium_id: stadium.id).first_or_create(source: 4, ticket_type: 0, mode: 1, status: 0, seat_type: 1)
                info_hash[1].each do |single_event_info_hash|
                  show_time = single_event_info_hash["DateVal"]

                  ticket_info_path = single_event_info_hash["EventUrl"]

                  temp_data = client.hget("viagogo_tickets_info", ticket_info_path)
                  if temp_data
                    ticket_info_array = JSON.parse temp_data
                  else
                    next
                  end

                  if ticket_info_array.present?
                    if event = Event.where(ticket_path: ticket_info_path).first
                      event.update(show_time: show_time, show_id: show.id)
                    else
                      event = Event.create(ticket_path: ticket_info_path, show_time: show_time, show_id: show.id)
                    end
                  else
                    next
                  end

                  #格式为{"section_id" => [{},...],...}
                  ticket_info_group_by_section_hash = ticket_info_array.group_by{|x| x["Section"]}
                  ticket_info_group_by_section_hash.each do |name_info_hash|
                    ticket_info_group_by_section_array = name_info_hash[1]
                    area_name = name_info_hash[0]

                    next if area_name.blank?

                    seats_count = ticket_info_group_by_section_array.inject(0){|sum, hash| sum + hash["MaxQuantity"]}
                    price_array = ticket_info_group_by_section_array.map{|x|x["RawPrice"]}.sort
                    max_price = price_array.last
                    price_range = "#{price_array.first} - #{max_price}"

                    if area = Area.where(name: area_name, event_id: event.id, stadium_id: stadium.id).first
                      area.update(seats_count: seats_count, left_seats: seats_count)
                      if relation = ShowAreaRelation.where(show_id: show.id, area_id: area.id).first
                        relation.update(price: max_price, price_range: price_range, seats_count: seats_count, left_seats: seats_count, third_inventory: seats_count)
                      else
                        ShowAreaRelation.create(show_id: show.id, area_id: area.id, price: max_price, price_range: price_range, seats_count: seats_count, left_seats: seats_count, third_inventory: seats_count)
                      end
                    else
                      area = Area.create(name: area_name, event_id: event.id, stadium_id: stadium.id, seats_count: seats_count, left_seats: seats_count)
                      ShowAreaRelation.create(show_id: show.id, area_id: area.id, price: max_price, price_range: price_range, seats_count: seats_count, left_seats: seats_count, third_inventory: seats_count)
                    end
                  end
                end
              end
            end
          end
        rescue Exception => e
          viagogo_logger.info "exception: #{e}"
        end
      end
    end

    def update_star_avatar
      #client = SSDB::Client.new.connect
      #if client.connected?
        #只更新avatar为nil的star
        #Star.where("event_path is not null and avatar is null").each do |star|
          #event_path = star.event_path
          #if event_path
            #cover_url = client.hget("viagogo_event_covers", event_path)
            #if cover_url
              #cover_url = cover_url[1..-2]

              #update_subject_url(star, cover_url)

              #shows = star.shows
              #if shows.present?
                #shows.each do |show|
                  #if show.poster_url.nil?
                    #update_subject_url(show, cover_url)
                  #end
                #end
              #end

            #end
          #end
        #end
      #end

      logo_json = JSON.parse(File.open("./public/nba_logos.json","r").readline)
      Star.where("event_path is not null and avatar is null").each do |star|
        url = logo_json[star.name.gsub("-", " ")]
        update_subject_url(star, url)
      end

    end

    def update_show_poster
      logo_json = JSON.parse(File.open("./public/nba_logos.json","r").readline)
      Show.where("source = 4 and poster is null").each do |show|
        stars = show.stars
        if ( stars.count == 2 )
          #确定主场队伍
          if show.name.start_with?(stars[0].name.gsub("-", " "))
            first_star = stars.first
            second_star = stars.last
          else
            first_star = stars.last
            second_star = stars.first
          end

          bg_url = logo_json["nbabg"]

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

    def combine_img(bg_img, over_img, position)
      bg_img.composite(over_img) do |c|
        c.compose "Over"
        c.geometry position
      end
    end

    def update_event_stadium_map
      client = SSDB::Client.new.connect
      if client.connected?
        #只更新stadium_map为nil的event
        Event.where("ticket_path is not null and stadium_map is null").each do |event|
          ticket_path = event.ticket_path
          if ticket_path
            map_url = client.hget("viagogo_stadium_maps", ticket_path)
            if map_url
              map_url = map_url[1..-2]
              update_subject_url(event, map_url)
            end
          end
        end
      end
    end

    def fetch_event_data(path)
      url = VIAGOGO_URL + path
      options = {"PageSize" => "950", "CurrentPage" => "1", "sortBy" => "POPULARITY", "sortDirection" => "0", "Quantity" => "0"}
      3.times do
        begin
          res = Timeout::timeout(5) { RestClient.post(url, options) } rescue nil
          if res
            res = JSON.parse res
            if res["Items"].any?
              return res["Items"]
            else
              next
            end
          else
            next
          end
        rescue Exception => e
          viagogo_logger.info "访问#{path}超时"
          next
        end
      end
      nil
    end

    def update_event_data(event, show, ticket_info_array, rate)
      #只取电子票
      ticket_info_array = ticket_info_array.select{|x| x["TicketTypeNotes"].present? && ( ( x["TicketTypeNotes"].include?( "E-Ticket" ) ) || ( x["TicketTypeNotes"].include?( "Instant Download" ) ) )}
      if ticket_info_array.present? && show && event
        #按区域名字分组
        ticket_info_group_by_section_hash = ticket_info_array.group_by{|x| x["Section"]}

        source_area_ids = event.areas.pluck(:id)
        updated_area_ids = []

        ticket_info_group_by_section_hash.each do |name_info_hash|
          area_name = name_info_hash[0]
          next if area_name.blank?

          ticket_info_group_by_section_array = name_info_hash[1]

          seats_count = ticket_info_group_by_section_array.inject(0){|sum, hash| sum + hash["MaxQuantity"]}
          price_array = ticket_info_group_by_section_array.map{|x| x["RawPrice"]}.sort
          max_price = ( price_array.last * SERVICE_FEE * rate ).to_i + 1
          price_range = "#{( price_array.first * rate ).to_i} - #{( price_array.last * rate ).to_i}"
          if area = Area.where(name: area_name, event_id: event.id).first_or_create(seats_count: 0, left_seats: 0)
            if relation = show.show_area_relations.where(area_id: area.id).first_or_create(seats_count: 0, left_seats: 0)
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
                  rest_tickets.times { show.seats.where(area_id: area.id).create(status:Ticket::seat_types[:avaliable], price: max_price) }
                #座位数量不变
                else
                  left_seats = relation.left_seats
                end
              end
              area.update(stadium_id: show.stadium.id, seats_count: seats_count, left_seats: left_seats, is_exist: true)
              relation.update(price: max_price, price_range: price_range, seats_count: seats_count, left_seats: left_seats)
            end
            updated_area_ids << area.id
          end
        end

        #官网不存在的area
        not_exist_ids = source_area_ids - updated_area_ids
        Area.where("id in (?)", not_exist_ids).update_all(is_exist: false)
      end
    end

    def data_clear
      ["Star", "Concert", "City", "Stadium", "Show", "Event", "Area", "ShowAreaRelation"].each{ |x| Object::const_get(x).delete_all }
    end

    def data_to_hoishow
      #data_transform
      nba_data
      update_star_avatar
      update_show_poster
      update_event_stadium_map
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

    def nba_data
      client = SSDB::Client.new.connect

      if client.connected?

        unless rate = get_exchange_rate
          viagogo_logger.info "实时汇率获取失败"
          return
        end

        default_description = "<span style=\"line-height: 1.42857;\">1. 本场比赛为海外赛事，系统需要确定库存和价格，购票支付成功后 24 小时内将会提供出票状态，出票成功将会以短信形式通知；如出票失败，订单金额将会原路退还；</span><p></p><p><span style=\"line-height: 1.42857;\">2. 本场比赛出票形式为电子票，不支持快递配送业务。成功购票后，订票手机号将会收到电子门票的下载地址，届时凭自助打印纸质票进场；</span></p><p><span style=\"line-height: 1.42857;\">3. 海外体育赛事日期和时间为当地时间，请购票前核对时间信息；</span></p><p><span style=\"line-height: 1.42857;\">4. 赛事门票具有唯一性、时效性等特殊属性，如非比赛变更、取消、票品错误原因外，不提供退还票品服务，购票时请务必仔细核对活动信息；</span></p><p>最终解释权归 <b>单车娱乐</b> 所有</p><p></p><p></p><p></p><p></p><p></p>"

        data = client.hgetall("viagogo_events")

        nba_team_paths = data.values.select{|x| x.start_with? "\"/Sports-Tickets/NBA/NBA-Regular-Season"}.map{|x| x = x[1..-2]}

        #nba_team_paths = ["/Sports-Tickets/NBA/NBA-Regular-Season/Washington-Wizards-Tickets", "/Sports-Tickets/NBA/NBA-Regular-Season/Detroit-Pistons-Tickets"]
        
        #所有的链接
        #event_path_array = client.hgetall("viagogo_hot_events", :list).map{|x| JSON.parse x}.flatten

        begin
          nba_team_paths.each do |path|
            if event_info = client.hget("viagogo_events_info", path)
              event_info = JSON.parse event_info
            else
              next
            end

            if event_info.present?
              star_name = path.split("/").last[0..-9]
              Star.transaction do
                unless star = Star.where(event_path: path).first
                  star = Star.create(name: star_name, event_path: path)
                end

                event_info.each do |event_info_hash|
                  if concert_name = event_info_hash["EventName"]
                    concert = Concert.where(name: concert_name).first_or_create(is_show: "auto_hide", status: "finished")
                    star.hoi_concert(concert)
                  else
                    next
                  end

                  show_time = event_info_hash["DateVal"]

                  ticket_info_path = event_info_hash["EventUrl"]
                  event_url_id = ticket_info_path.split("/").last

                  stadium_name = event_info_hash["VenueName"]
                  city_name = event_info_hash["VenueCity"]
                  if stadium_name && city_name
                    city = City.where(source_name: city_name).first_or_create(name: city_name)
                    stadium = Stadium.where(source_name: stadium_name, city_id: city.id).first_or_create(name: stadium_name, longitude: 0.0, latitude: 0.0)
                  else
                    next
                  end

                  show = Show.where(event_url_id: event_url_id).first_or_create(name: concert_name, concert_id: concert.id, city_id: city.id, stadium_id: stadium.id, source: 4, ticket_type: 0, mode: 1, status: 0, seat_type: 1, description: default_description)
                  
                  ticket_info = client.hget("viagogo_tickets_info", ticket_info_path)
                  if ticket_info
                    ticket_info = JSON.parse ticket_info
                  else
                    next
                  end

                  if ticket_info.present?
                    #for sports ticket,有两个入口
                    events = show.events
                    if events.count > 0
                      event = events.last
                    #if event = Event.where(ticket_path: ticket_info_path).first
                      event.update(show_time: show_time)
                    else
                      event = Event.create(ticket_path: ticket_info_path, show_time: show_time, show_id: show.id)
                    end
                  else
                    next
                  end

                  update_event_data(event, show, ticket_info, rate)

                end
              end

            else
              next
            end

          end
        rescue Exception => e
          viagogo_logger.info "exception: #{e}"
        end

      end

    end

    def get_exchange_rate
      url = "http://api.fixer.io/latest?base=USD"
      5.times do
        begin
          res = Timeout::timeout(5) { RestClient.get url } rescue nil
          if res
            res = JSON.parse res
            return res["rates"]["CNY"]
          else
            next
          end
        rescue Exception => e
          viagogo_logger.info "访问#{url}超时"
          next
        end
      end
      nil
    end

    def upyun_upload
      config = {bucket: 'hoishow-img', secret: 'Q0DnSXzf9xCbSAXbtQMI4ljI27c=', notify_url: 'http://111', save_path: 'uploads/nba/img'}
      up = UpyunFormUpload::Service::Uploader.new config
      name_logos = {}
      host_url = "http://hoishow-img.b0.upaiyun.com"

      #明星logo
      Star.where("event_path is not null").each do |star|
        url = "/Users/apple/Downloads/nba/logos360/#{star.name.gsub("-", " ")}.png"
        res = up.put url
        if res["code"] == 200
          name_logos = name_logos.merge({res["ext-param"] => ( host_url + res["url"] )})
        end
      end

      #背景图
      path = "/Users/apple/Downloads/nba/nbabg.jpg"
      res = up.put path
      if res["code"] == 200
        name_logos = name_logos.merge({res["ext-param"] => ( host_url + res["url"] )})
      end

      File.open("./public/nba_logos.json","w"){|f| f << name_logos.to_json }

    end

  end
end
