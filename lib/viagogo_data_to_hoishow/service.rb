# encoding: utf-8
require 'timeout'
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
        #用sidekiq更新所有event场馆图
        b.report("update_events_stadium_map:"){update_events_stadium_map}
        #
        #b.report("update_show_poster:"){update_show_poster}
      end
    end

    def data_transform
      ssdb = SSDB::Client.new.connect
      if ssdb.connected?

        default_description = ViagogoSetting["default_description"]

        unless categories = get_categories
          viagogo_logger.info "获取categories失败"
          return
        end

        categories.each do |table, category_hash|
          category_hash.each do |category_id, category_name|
            unless event_ids = get_event_ids(category_id, table)
              viagogo_logger.info "获取event_ids失败"
              next
            end

            category_name[0] = ""
            category_name[-1] = ""

            event_ids.each do |event_id|
              event_json = ssdb.hget("viagogo_#{table}_events_by_#{category_id}", event_id)
              unless event_json
                viagogo_logger.info "获取single_event失败"
                next
              end
              event_json = JSON.parse(event_json)
              concert_name = event_json["name"].force_encoding("utf-8")

              Event.transaction do
                concert = Concert.where(name: concert_name).first_or_create(is_show: "auto_hide", status: "finished")

                venue_json = event_json["_embedded"]["venue"]
                city_name = venue_json["city"].force_encoding("utf-8")
                city = City.where(source_name: city_name).first_or_create(name: city_name, source: 4)
                stadium_name = venue_json["name"].force_encoding("utf-8")
                stadium = Stadium.where(source_name: stadium_name, city_id: city.id).first_or_create(name: stadium_name, longitude: venue_json["longitude"], latitude: venue_json["latitude"], source: 4)

                show = Show.where(source_name: concert_name, stadium_id: stadium.id)
                  .first_or_create({
                  name: concert_name,
                  concert_id: concert.id,
                  city_id: city.id,
                  source: 4,
                  ticket_type: 0,
                  mode: 1,
                  status: 0,
                  seat_type: 1,
                  description: default_description,
                  is_display: 1,
                  show_type: category_name.force_encoding("utf-8")
                })

                  #时间数据格式"2016-04-29T13:20:00-05:00"
                  show_time = DateTime.strptime(event_json["start_date"], '%Y-%m-%dT%H:%M') - 8.hours

                  event = Event.where(ticket_path: event_json["id"].to_s).first_or_create(show_time: show_time, show_id: show.id)
                  event.update(show_time: show_time)
              end
            end
          end
        end
      else
        viagogo_logger.info "data_transform连接不到ssdb"
        return
      end
    end

    def update_events_data
      events = Event.where("ticket_path is not null and is_display is true")
      #events.each{|event| UpdateViagogoEventWorker.perform_async(event.id)}
      events.each{|event| update_event_data_with_api(event.id)}
    end

    #返回success变量来区别是否更新数据成功
    def update_event_data_with_api(event_id)
      ssdb = SSDB::Client.new.connect
      unless ssdb.connected?
        viagogo_logger.info "update_events_data连接不到ssdb"
        return
      end

      success = false
      event = Event.find(event_id)
      show = event.show
      if show.present? && event.present?
        type_map = Rails.cache.read("type_map")
        return nil unless type_map
        category = type_map[show.show_type]
        listings_json_array = ssdb.hgetall("viagogo_#{category}_listings_by_#{event.ticket_path}", :list).map{|i| JSON.parse i}
        if listings_json_array.present?
          e_ticket_items = listings_json_array.select{|i| i["_embedded"]["ticket_type"]["type"].include?("ETicket")}
          return nil if e_ticket_items.size < 1
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
              total_fee = booking_fee + shipping + vat
              if total_fee < 1 or i["number_of_tickets"] < 1
                ticket_price
              else
                ticket_price + ( ( total_fee ) / i["number_of_tickets"] ).round(2)
              end
            end.compact.sort

            #价格为(单价加上预约费)X汇率
            max_price = price_array.last.to_i + 200
            price_range = "#{price_array.first.to_i + 200} - #{max_price}"

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
          success = true
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

    def update_events_stadium_map
      events = Event.where("ticket_path is not null and stadium_map is null and is_display is true")
      events.each{|event| UpdateViagogoStadiumMapWorker.perform_async(event.id)}
    end

    def update_event_stadium_map_with_api(event_id)
      ssdb = SSDB::Client.new.connect
      unless ssdb.connected?
        viagogo_logger.info "update_events_stadium_map连接不到ssdb"
        return
      end

      event = Event.find(event_id)
      show = event.show
      if event.present? && show.present?
        type_map = Rails.cache.read("type_map")
        return nil unless type_map
        category = type_map[show.show_type]
        map_url = ssdb.hget("viagogo_#{category}_stadium_maps", event.ticket_path)
        update_subject_url(event, map_url) unless map_url.blank?
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

    def get_event_ids(category_id, table)
      ssdb = SSDB::Client.new.connect
      if ssdb.connected?
        result = ssdb.exec(["hsize", "viagogo_#{table}_events_by_#{category_id}"])
        if result.first == "ok"
          ids_array = ssdb.exec(["hkeys", "viagogo_#{table}_events_by_#{category_id}", "", "", result.last])
          if ids_array.first == "ok"
            ids_array.delete("ok")
            return ids_array
          end
        end
      end
      nil
    end

    def get_categories
      ssdb = SSDB::Client.new.connect
      if ssdb.connected?
        type_map = {}
        result = {}
        ["sport", "theater", "concert", "festival"].each do |category|
          #{"1006"=>"\"Cricket\"",...}
          data = ssdb.hgetall("viagogo_#{category}_types")
          result.merge!( {category => data} )

          #创建缓存数据
          types = ssdb.hgetall("viagogo_#{category}_types", :list)
          cache_data = types.map do |type|
            type[0] = ""
            type[-1] = ""
            [type.force_encoding("utf-8"), category]
          end
          type_map.merge!(Hash[cache_data])
        end
        #写缓存
        Rails.cache.write("type_map", type_map)

        result
      else
        nil
      end
    end

    def data_clear
      ["Star", "Concert", "City", "Stadium", "Show", "Event", "Area", "ShowAreaRelation", "Ticket"].each{ |x| Object::const_get(x).delete_all }
    end

  end
end
