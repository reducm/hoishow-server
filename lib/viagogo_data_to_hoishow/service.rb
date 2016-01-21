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
        #ticket_info_hash = client.hgetall("viagogo_tickets_info")

        #只取concert的票
        #不一次过取出全部，用event_path来逐个取出，在需要用的时候
        #:list参数只取values，不取keys
        #event_path_array = event_info_hash.keys
        #event_path_array = event_info_hash.keys.select{|x| x.include? "/Concert-Tickets/"}

        event_path_array = client.hgetall("viagogo_events", :list).select{|x| x.include? "/Concert-Tickets/"}.map{|x| x = x[1..-2]}

        star_position = Star.maximum("position").to_i + 1
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
              star = Star.where(name: star_name, event_path: event_path, position: star_position).first_or_create
              star_position = star_position + 1
              concert = Concert.create(name: "#{star.id}(自动生成)", is_show: "auto_hide", status: "finished")
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
              city = City.where(name: city_name).first_or_create!
              stadium = Stadium.where(name: stadium_name, city_id: city.id).first_or_create!
              show = Show.where(source: 4, name: (star_name + " In " + stadium_name), concert_id: concert.id, city_id: city.id, stadium_id: stadium.id).first_or_create!(ticket_type: 1, mode: 1, status: 0, seat_type: 1)
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
                  event = Event.where(show_time: show_time, show_id: show.id, ticket_path: ticket_info_path).first_or_create!
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
                  area = Area.where(name: area_name, event_id: event.id, stadium_id: stadium.id).first_or_create!(seats_count: seats_count, left_seats: seats_count)

                  price_array = ticket_info_group_by_section_array.map{|x|x["RawPrice"]}.sort
                  max_price = price_array.last
                  price_range = "#{price_array.first} - #{max_price}"
                  ShowAreaRelation.where(show_id: show.id, area_id: area.id).first_or_create!(price: max_price, price_range: price_range, seats_count: seats_count, left_seats: seats_count, third_inventory: seats_count)
                end
              end
            end
          end
        end
      end
    end

    def update_star_cover
      client = SSDB::Client.new.connect
      if client.connected?
        Star.all.each do |star|
          event_path = star.event_path
          if event_path
            cover_url = client.hget("viagogo_event_covers", event_path)
            if cover_url
              cover_url = cover_url[1..-2]

              3.times do
                begin
                  temp = 
                    Timeout::timeout(5) do
                      star.remote_poster_url = cover_url  
                      star.save!
                    end
                  if temp
                    viagogo_logger.info "star_id: #{star.id} 更新poster成功"
                    break
                  else
                    viagogo_logger.info "star_id: #{star.id} timeout, 即将重试"
                    next
                  end
                rescue Exception => e
                  viagogo_logger.info "star_id: #{star.id} exception, 即将重试"
                  next
                end
              end

              shows = star.shows
              if shows.present?
                shows.each do |show|
                  3.times do
                    begin
                      temp = 
                        Timeout::timeout(5) do
                          show.remote_poster_url = cover_url  
                          show.save!
                        end
                      if temp
                        viagogo_logger.info "show_id: #{show.id} 更新poster成功"
                        break
                      else
                        viagogo_logger.info "show_id: #{show.id} timeout, 即将重试"
                        next
                      end
                    rescue Exception => e
                      viagogo_logger.info "show_id: #{show.id} exception, 即将重试"
                      next
                    end
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
        Event.all.each do |event|
          ticket_path = event.ticket_path
          if ticket_path
            map_url = client.hget("viagogo_stadium_maps", ticket_path)
            if map_url
              map_url = map_url[1..-2]

              3.times do
                begin
                  temp = 
                    Timeout::timeout(5) do
                      event.remote_stadium_map_url = map_url  
                      event.save!
                    end
                  if temp
                    viagogo_logger.info "event_id: #{event.id} 更新stadium_map成功"
                    break
                  else
                    viagogo_logger.info "event_id: #{event.id} timeout, 即将重试"
                    next
                  end
                rescue Exception => e
                  viagogo_logger.info "event_id: #{event.id} exception, 即将重试"
                  next
                end
              end

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

  end
end
