# coding: utf-8
require 'timeout'

module ViagogoDataToHoishow
  module Service
    extend ViagogoLogger
    extend self

    VIAGOGO_URL = "http://www.viagogo.com"

    def data_transform
      client = SSDB::Client.new.connect
      if client.connected?
        #key为"/Concert-Tickets/Alternative-and-Indie/Adele-Tickets"
        #event_info_hash = client.hgetall("viagogo_events_info")

        #key为"/cn/Concert-Tickets/Alternative-and-Indie/Adele-Tickets/E-1389466"

        #只取concert的票
        #不一次过取出全部，用event_path来逐个取出，在需要用的时候
        #:list参数只取values，不取keys

        #event_path_array = client.hgetall("viagogo_events", :list).select{|x| x.include? "/Concert-Tickets/"}.map{|x| x = x[1..-2]}

        event_path_array = client.hgetall("viagogo_hot_events", :list).map{|x| JSON.parse x}.flatten

        Star.transaction do
          event_path_array.each do |event_path|
            #event_info_array为event的所有场次信息
            #格式为[{info_hash},{},{}...]
            #temp_data = event_info_hash[event_path]

            #每次都从ssdb取出，减少服务器负担
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
                return nil unless concert
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
              show = Show.where(name: (star_name + " In " + stadium_name), concert_id: concert.id, city_id: city.id, stadium_id: stadium.id).first_or_create(source: 4, ticket_type: 1, mode: 1, status: 0, seat_type: 1)
              info_hash[1].each do |single_event_info_hash|
                show_time = single_event_info_hash["DateVal"]

                ticket_info_path = single_event_info_hash["EventUrl"]

                #ticket_info_array为event的所有区域信息
                #格式为[{info_hash},{},{}...]
                #temp_data = ticket_info_hash[ticket_info_path]
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

                  if area_name.blank?
                    next
                  end

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
      end
    end

    def update_star_avatar
      client = SSDB::Client.new.connect
      if client.connected?
        #Star.all.each do |star|
        #只更新avatar为nil的star
        Star.where(avatar: nil).each do |star|
          event_path = star.event_path
          if event_path
            cover_url = client.hget("viagogo_event_covers", event_path)
            if cover_url
              cover_url = cover_url[1..-2]

              update_subject_url(star, cover_url)

              shows = star.shows
              if shows.present?
                shows.each do |show|
                  if show.poster_url.nil?
                    update_subject_url(show, cover_url)
                  end
                end
              end

            end
          end
        end
      end
    end

    def update_event_stadium_map
      client = SSDB::Client.new.connect
      if client.connected?
        #Event.all.each do |event|
        #只更新stadium_map为nil的event
        Event.where(stadium_map: nil).each do |event|
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
      res = Timeout::timeout(8) { RestClient.post(url, options) }
      if res
        res = JSON.parse res
        res["Items"]
      else
        viagogo_logger.info "访问#{path}超时"
        nil
      end
    end

    def data_clear
      ["Star", "Concert", "City", "Stadium", "Show", "Event", "Area", "ShowAreaRelation"].each{ |x| Object::const_get(x).delete_all }
    end

    def data_to_hoishow
      data_transform
      update_star_avatar
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
                  subject.remote_avatar_url = url  
                when "Show"
                  subject.remote_poster_url = url  
                when "Event"
                  subject.remote_stadium_map_url = url  
                end
                subject.save!
              end
            if temp
              viagogo_logger.info "更新#{subject_class}_id: #{subject.id}成功"
              break
            else
              viagogo_logger.info "#{subject_class}_id: #{subject.id} timeout, 即将重试"
              next
            end
          rescue Exception => e
            viagogo_logger.info "#{subject_class}_id: #{subject.id} exception, 即将重试"
            next
          end
        end
      end
    end

  end
end
