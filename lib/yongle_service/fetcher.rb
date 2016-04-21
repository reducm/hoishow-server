require 'benchmark'
require 'mini_magick'

module YongleService
  module Fetcher
    extend YongleService::Service
    extend YongleService::Logger
    extend self

    # 日数据
    def fetch_day_data
      Benchmark.bm do |b|
        b.report "fetching day data...\n" do
          fetch_play_types
          fetch_cities
          fetch_city_products
        end
      end
    end

    # 爬取单个商品
    # TODO maybe reuse this method in #fetch_products
    def fetch_product(show_source_id)
      result_data = YongleService::Service.get_product(show_source_id)
      if result_data["result"] == '1000'
        product = result_data["data"]["products"]["product"]
        Show.transaction do
          # City
          city_source = CitySource.find_by(yl_fconfig_id: product["fconfigId"].to_i, source: CitySource.sources['yongle'])
          city_source.update!(source_id: product["playCityId"].to_i)
          city = city_source.city
          # Stadium
          stadium = fetch_stadium(product["playAddressId"].to_i, city)
          # Star and Concert
          concert = fetch_star_and_concert(product)
          return unless stadium.present? && concert.present? # 有可能调场馆接口时网络失败，暂定跳过
          # Show
          show = fetch_show(product, city, stadium, concert)
          return unless show.present?
          ticket_time_list = product["ticketTimeList"]
          return unless ticket_time_list.present? # 跳过没有场次的票品
          tti = ticket_time_list["ticketTimeInfo"]
          ticket_time_infos = tti.class == Array ? tti : [tti] # 如果永乐返回单个hash把它塞进数组，统一作为数组处理
          ticket_time_infos.each do |ticket_time_info|
            # Event
            event = fetch_event(product, ticket_time_info["ticketTime"], show)
            next unless event.present?
            @fetch_area_ids = []
            tsi = ticket_time_info["tickSetInfoList"]["tickSetInfo"]
            tick_set_infos = tsi.class == Array ? tsi : [tsi] # 只有一种票价区会返回hash
            # Area and relation and Seat
            fetch_area_relation_and_seat(tick_set_infos, event, show)
            empty_inventory(@fetch_area_ids, event) if @fetch_area_ids.any?
            event.update(is_display: false) if event.areas.blank? # 隐藏没有票区的场次
          end
          if show.events.blank? # 没有场次的演出，如果没有下过单就直接删除，否则隐藏
            show.orders.blank? ? show.concert.destroy : show.update(is_display: false)
          end
        end
        yongle_logger.info "Product #{show_source_id} fetch finished."
      elsif result_data["result"] == '1003'
        yongle_logger.info "Product doesn't exist!"
      else
        yongle_logger.info "Fetch fail!"
        yongle_logger.info "result_data: #{result_data}"
      end
    end

    # 票区实时数据
    def fetch_productprice_info(area_source_id)
      area = Area.where(source_id: area_source_id, source: Area.sources['yongle']).first
      relation = area.show_area_relations.first
      yongle_logger.info "relation.id: #{relation.id}"
      result_data = YongleService::Service.find_productprice_info(area_source_id)
      yongle_logger.info "result_data: #{result_data}"
      if result_data["result"] == '1000'
        result_data = result_data["data"]["tickSetInfo"]
        area.update!(name: result_data["priceInfo"])
        relation.update!(price: result_data["price"].to_i)
        not_enough_inventory = result_data["priceNum"].to_i < 0 && result_data["priceNum"].to_i != -1 # 暂定－1以外的负数库存不可卖
        not_for_sell = ['1', '4'].exclude?(result_data["priceStarus"]) # 联盟可卖状态为1、4
        if not_enough_inventory || not_for_sell
          seats_count = 0
        elsif result_data["priceNum"].to_i == -1 # 永乐无限库存
          seats_count = 30
          area.update!(is_infinite: true)
        else
          seats_count = result_data["priceNum"].to_i
        end
        update_inventory(area.shows.first, area, relation, seats_count, result_data["price"].to_i)
      elsif result_data["result"] == '1003' # 假设永乐把该票区删掉了
        seats_count = 0
        update_inventory(area.shows.first, area, relation, seats_count, result_data["price"].to_i)
      end
      yongle_logger.info "Fetch finished, relation.seats_count: #{relation.seats_count}, relation.left_seats: #{relation.left_seats}"
    end

    def fetch_play_types
      yongle_logger.info ">start fetching Yongle's play types..."
      result_data = YongleService::Service.all_category
      if result_data["result"] == '1000' # 成功
        YlPlayType.transaction do
          result_data["data"]["Response"]["getPlayTypeRsp"]["playTypeAList"]["playTypeAInfo"].each do |type_a|
            type_a["playTypeBList"]["playTypeBInfo"].each do |type_b|
              YlPlayType.where(
                play_type_a_id: type_a["playTypeAId"].to_i,
                play_type_a:    type_a["playTypeA"],
                play_type_b_id: type_b["playTypeBId"].to_i,
                play_type_b:    type_b["playTypeB"]
              ).first_or_create!
            end
          end
        end
      end
      yongle_logger.info ">finish fetching Yongle's play types."
    end

    def fetch_cities
      yongle_logger.info ">start fetching Yongle's cities..."
      result_data = YongleService::Service.get_all_fconfig
      if result_data["result"] == '1000' # 成功
        CitySource.transaction do
          result_data["data"]["Response"]["getFconfigRsp"]["fconfigInfo"].each do |yongle_city|
            name = yongle_city["playCity"].gsub('市', '').gsub('特别行政区', '')
            city_source = CitySource.where(yl_fconfig_id: yongle_city['fconfigId'].to_i, source: CitySource.sources['yongle']).first_or_initialize
            if city_source.new_record?
              city = City.where(name: name).first_or_create!
              city_source.city = city
            end
            city_source.update!(name: name,code: yongle_city['citycode'])
          end
        end
      end
      yongle_logger.info ">finish fetching Yongle's cities."
    end

    def fetch_city_products
      @total_spend = 0
      @show_fetched = 0
      city_codes = CitySource.where('yl_fconfig_id IS NOT NULL AND source = ?', CitySource.sources["yongle"]).pluck(:code).uniq.compact
      if city_codes.any?
        city_codes.each do |citycode|
          @cityname = CitySource.find_by(code: citycode).name
          yongle_logger.info ">fetching from #{@cityname}"
          fetch_start = Time.now
          result_data = YongleService::Service.get_city_data(citycode)
          fetch_end = Time.now
          @total_spend = @total_spend + (fetch_end - fetch_start)
          yongle_logger.info "...Total spends: #{(@total_spend/60).floor}:#{(@total_spend%60).floor}.\n"
          if result_data["result"] == '1000' && result_data["data"].present? # 成功且有数据
            yl_product = result_data["data"]["products"]["product"]
            products = yl_product.class == Array ? yl_product : [yl_product] # 只有一场演出会返回hash
            fetch_products(products) if products.any? # 跳过没有票品的城市
          end
        end
      end
    end

    def fetch_image(show_id, url, image_desc)
      show = Show.find(show_id)
      begin
        case image_desc
        when 'poster'
          # TODO resize first if image is not 288x384
          unless show.poster_url.present?
            convert_image(show_id, url)
          end
        when 'ticket_pic'
          show.remote_ticket_pic_url = url unless show.ticket_pic_url.present?
        when 'stadium_map'
          show.remote_stadium_map_url = url unless show.stadium_map_url.present?
        end
        show.save!
      rescue => e
        yongle_logger.info "更新#{image_desc}出错，#{e}"
      end
    end

    ############ private method ############

    def fetch_products(products)
      Show.transaction do
        products.each_with_index do |product, i|
          unit_start = Time.now
          yongle_logger.info ">>#{@cityname}(#{i + 1}/#{products.count})"
          # City
          city_source = CitySource.where(yl_fconfig_id: product["fconfigId"].to_i, source: CitySource.sources['yongle']).first
          city_source.update!(source_id: product["playCityId"])
          city = city_source.city
          # Stadium
          stadium = fetch_stadium(product["playAddressId"], city)
          # Star and Concert
          concert = fetch_star_and_concert(product)
          if stadium.present? && concert.present? # 有可能调场馆接口时网络失败，暂定跳过
            # Show
            show = fetch_show(product, city, stadium, concert)
            if show.present?
              ticket_time_list = product["ticketTimeList"]
              if ticket_time_list # 跳过没有场次的票品
                tti = ticket_time_list["ticketTimeInfo"]
                ticket_time_infos = tti.class == Array ? tti : [tti] # 只有一个场次会返回hash
                ticket_time_infos.each do |ticket_time_info|
                  # Event
                  event = fetch_event(product, ticket_time_info["ticketTime"], show)
                  if event.present?
                    @fetch_area_ids = []
                    tsi = ticket_time_info["tickSetInfoList"]["tickSetInfo"]
                    tick_set_infos = tsi.class == Array ? tsi : [tsi] # 只有一种票价区会返回hash
                    # Area and relation and Seat
                    fetch_area_relation_and_seat(tick_set_infos, event, show)
                    empty_inventory(@fetch_area_ids, event) if @fetch_area_ids.any?
                    event.update(is_display: false) if event.areas.blank? # 隐藏没有票区的场次
                  end
                end
                if show.events.blank? # 没有场次的演出如果没有下过单就直接删除，否则隐藏
                  show.orders.blank? ? show.concert.destroy : show.update(is_display: false)
                end
              end
            end
          end
          unit_end = Time.now
          @total_spend = @total_spend + (unit_end - unit_start)
          @show_fetched = @show_fetched + 1
          yongle_logger.info "...Total spends: #{(@total_spend/60).floor}:#{(@total_spend%60).floor}"
          yongle_logger.info "...Show fetched: #{@show_fetched}"
          yongle_logger.info "...Speed: #{(@show_fetched/@total_spend * 60).round(1)} shows/m.\n"
        end
      end
    end

    def fetch_stadium(source_id, city)
      result_data = YongleService::Service.get_venue_info(source_id)
      if result_data["result"] == '1000' # 成功
        venue = result_data["data"]["Response"]["getVenueInfoRsp"]["venue"]
        stadium = city.stadiums.where(source_id: venue["venueId"].to_i, source: Stadium.sources["yongle"]).first_or_initialize
        stadium.update(
          name:       venue["venueName"],
          address:    venue["address"],
          longitude:  venue["longitude"].to_f - 0.0065,
          latitude:   venue["latitude"].to_f - 0.006
        )

        stadium
      end
    end

    def fetch_star_and_concert(product)
      show = Show.where(source_id: product["productId"].to_i, source: Show.sources["yongle"]).first
      if show.present?
        concert = show.concert
      else
        concert = Concert.create(
          name: "(自动生成)" + product["playName"],
          is_show: "auto_hide",
          status: "finished",
          start_date: Time.now,
          end_date: Time.now + 1
        )
      end

      performer = product["performer"]
      if performer.present?
        performer.split('、').each do |name|
          star = Star.where(name: name).first_or_create!
          star.hoi_concert(concert)
        end
      end
      concert
    end

    def fetch_show(product, city, stadium, concert)
      if ['0', '1'].include?(product["status"]) && product["shelfStatus"].to_i == 1 # 跳过不可卖的
        if product["ProductProfile"].length > 65535 # 跳过各种电影卡
          yongle_logger.info "跳过各种电影卡, length: #{product["ProductProfile"].length}"
          return nil
        else
          show = stadium.shows.where(source_id: product["productId"].to_i, source: Show.sources["yongle"]).first_or_initialize

          show.update(
            concert_id:         concert.id,
            city_id:            city.id,
            yl_play_city_id:    product["playCityId"].to_i,
            yl_fconfig_id:      product["fconfigId"].to_i,
            yl_play_address_id: product["playAddressId"].to_i,
            yl_play_type_a_id:  product["playTypeAId"].to_i,
            yl_play_type_b_id:  product["playTypeBId"].to_i,
            name:               product["playName"],
            description:        product["ProductProfile"],
            status:             Show.statuses["selling"],
            is_presell:         product["status"].to_i == 1,
            ticket_type:        product["dispatchWayList"]["dzp_dispatchWay"].to_i == 1 ? Show.ticket_types["e_ticket"] : Show.ticket_types["r_ticket"],
            yl_dzp_type:        product["dispatchWayList"]["dzp_dispatchWay"].to_i == 1 ? Show.yl_dzp_types[product["dispatchWayList"]["dzp_type"]] : nil, # 电子票类型
            seat_type:          Show.seat_types["selected"]
          )

          # skip "wutuwulong"
          FetchImageWorker.perform_async(show.id, product["productPicture"], 'poster') if product["productPicture"].exclude?("wutuwulogo")
          FetchImageWorker.perform_async(show.id, product["productPictureSmall"], 'ticket_pic') if product["productPictureSmall"].exclude?("wutuwulogo")
          FetchImageWorker.perform_async(show.id, product["seatPicture"], 'stadium_map') if product["seatPicture"].exclude?("wutuwulogo")

          show
        end
      else
        show = stadium.shows.find_by(source_id: product["productId"].to_i, source: Show.sources["yongle"])
        # 有可能之前状态可卖，现在变成不可卖
        if show.present?
          show.update!(status: Show.statuses['sell_stop'])
        else
          concert.delete # 不然concert会越来越多
        end
        return nil
      end
    end

    def fetch_event(product, ticket_time, show)
      # "2015-11-15-2016-05-08-10:00"这种场次的，不做拉取
      begin
        show_time = DateTime.strptime(ticket_time, '%Y-%m-%d %H:%M') - 8.hours
        show.events.where(show_time: show_time).first_or_create
      rescue => e
        yongle_logger.info "跳过特殊场次, #{e}"
        return nil
      end
    end

    def fetch_area_relation_and_seat(tick_set_infos, event, show)
      tick_set_infos.each do |tick_set_info|
        area = event.areas.where(source_id: tick_set_info["productPlayid"].to_i, source: Area.sources['yongle']).first_or_initialize
        area.update!(name: tick_set_info["priceInfo"], stadium_id: show.stadium.id)
        @fetch_area_ids.push(area.id)
        relation = show.show_area_relations.where(area_id: area.id).first_or_initialize
        relation.update!(price: tick_set_info["price"])
        not_enough_inventory = tick_set_info["priceNum"].to_i < 0 && tick_set_info["priceNum"].to_i != -1 # 暂定－1以外的负数库存不可卖
        not_for_sell = ['1', '4'].exclude?(tick_set_info["priceStarus"]) # 联盟可卖状态为1、4
        if not_enough_inventory || not_for_sell
          seats_count = 0
        elsif tick_set_info["priceNum"].to_i == -1 # 永乐无限库存
          seats_count = 30
          area.update!(is_infinite: true)
        else
          seats_count = tick_set_info["priceNum"].to_i
        end
        update_inventory(show, area, relation, seats_count, tick_set_info["price"].to_i)
      end
    end

    def update_inventory(show, area, relation, seats_count, price)
      old_seats_count = relation.seats_count
      old_left_seats = relation.left_seats

      if old_seats_count > seats_count #减少了座位
        rest_tickets = old_seats_count - seats_count
        show.seats.where('area_id = ? and order_id is null', area.id).limit(rest_tickets).destroy_all
        new_left_seats = old_left_seats - rest_tickets
        relation.update(left_seats: new_left_seats, seats_count: seats_count)
        area.update(left_seats: new_left_seats, seats_count: seats_count)
      elsif old_seats_count < seats_count #增加了座位
        rest_tickets = seats_count - old_seats_count

        # sinagle mass insert
        inserts = []
        timenow = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        show_id = show.id
        area_id = area.id
        status = Ticket::statuses[:pending]
        seat_type = Ticket::seat_types[:avaliable]
        rest_tickets.times do
          inserts.push "(#{show_id}, #{area_id}, #{status}, #{seat_type}, #{price}, '#{timenow}', '#{timenow}')"
        end
        sql = "INSERT INTO tickets (show_id, area_id, status, seat_type, price, created_at, updated_at) VALUES #{inserts.join(', ')}"
        ActiveRecord::Base.connection.execute sql
        #####################

        relation.update(left_seats: rest_tickets + old_left_seats, seats_count: seats_count)
        area.update(left_seats: rest_tickets + old_left_seats, seats_count: seats_count)
      end
    end

    def empty_inventory(fetch_area_ids, event) # 永乐没有的票区清空库存
      event_area_ids = event.areas.pluck(:id)
      delete_area_ids = event_area_ids - fetch_area_ids
      event.areas.where(id: delete_area_ids).each do |a|
        relation = a.show_area_relations.first
        a.update(seats_count: 0, left_seats: 0)
        relation.update(seats_count: 0, left_seats: 0)
      end
    end

    def convert_image(show_id, url)
      time = Time.now
      yongle_logger.info "====== begin at #{time}"
      image = MiniMagick::Image.open(url)
      MiniMagick::Tool::Convert.new do |convert| # background image
        convert << image.path
        convert.merge! ["-resize", "720x405^", "-gravity", "center", "-extent", "720x405", "-gaussian-blur", "60x20"]
        convert << Rails.root.join("tmp/background#{show_id}.jpg")
      end
      background = MiniMagick::Image.open(Rails.root.join("tmp/background#{show_id}.jpg"))
      result = background.composite(image) do |c| # composite
        c.gravity "center"
      end
      result.write Rails.root.join("tmp/output#{show_id}.jpg")
      Show.find(show_id).update!(poster: File.open(Rails.root.join("tmp/output#{show_id}.jpg"))) # carrierwave 'upload' a loacal file
      yongle_logger.info "====== end at #{Time.now}, spend #{Time.now - time}"
    end

    class << self
      private :fetch_products
      private :fetch_stadium
      private :fetch_star_and_concert
      private :fetch_show
      private :fetch_event
      private :fetch_area_relation_and_seat
      private :update_inventory
      private :empty_inventory
      private :convert_image
    end
  end
end
