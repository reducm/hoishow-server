require 'benchmark'

begin
  file = File.open(File.join(Rails.root, 'db', 'city_district.json'), 'r')
  cities = JSON.parse(file.read)
  Benchmark.bm do |b|
    b.report "basic city data" do
      City.transaction do
        cities.each do |city_json|

          city = City.where(name: city_json["name"]).first_or_initialize

          city.update_attributes!(
            pinyin: city_json["pinyin"],
            code: city_json["code"],
            is_hot: city_json["hot"] || false
          )
        end
        City.create(pinyin:"xianggang", name:"香港", code:"000", is_hot:false)
        City.create(pinyin:"taiwan", name:"台湾", code:"000", is_hot:false)
        City.create(pinyin:"aomen", name:"澳门", code:"000", is_hot:false)
      end
    end
  end
rescue Exception => e
  ap $@
ensure
  file.close
end

city = City.first
stadium = Stadium.where(name: '首都体育馆', address: '北京市海淀区中关村南大街56号', city_id: city.id).first_or_create

stars = ['Coldplay', 'Eminem', 'Jay-z', 'Maroon 5', 'Linkin Park']

# star, concert, star_concert_relation, show
stars.each_with_index do |star, index|
  star = Star.where(name: star).first_or_create
  star.update_attributes!(position: index + 1)

  concert = Concert.where(name: "#{star.name}全球巡回演唱会", start_date: Time.now + 1.month, end_date: Time.now + 5.month, status: 0).first_or_create
  StarConcertRelation.where(star_id: star.id, concert_id: concert.id).first_or_create

  show = Show.where(name: "#{star.name}全球巡回演唱会#{city.name}站", show_time: Time.now + 1.month, min_price: 99, max_price: 1099, concert_id: concert.id, city_id: city.id, stadium_id: stadium.id, ticket_type: 0, seat_type: 0).first_or_create
  show.events.create

  Topic.where(creator_type: 'Star', creator_id: star.id, content: '大家快来看演唱会', subject_type: 'Star', subject_id: star.id).first_or_create
  Topic.where(creator_type: 'Star', creator_id: star.id, city_id: city.id, content: '演唱会真好看', subject_type: 'Concert', subject_id: concert.id).first_or_create
end

# area, show_area_relation
('a'..'e').to_a.each_with_index do |n, idx|
  area = Area.where(name: n, seats_count: 100, stadium_id: stadium.id).first_or_create
  price = idx + 100
  sar = ShowAreaRelation.where(show_id: Show.first.id, area_id: area.id, price: price,
                               seats_count: 1000, left_seats: 1000).first_or_create

  if sar.id == 1
    1000.times do Seat.create(show_id: sar.show_id, area_id: sar.area_id, price: price) end
  end
end

# admin
admin = Admin.create(name: 'admin', admin_type: 0)
admin.set_password('123')
admin.save

# user, order, ticket
concert = Concert.first
show = Show.first
Benchmark.bm do |b|
  b.report "order and ticket data" do
    if Area.count < 5 # 有数据的话就不创建了
      # 每个区的订单和票都不一样
      Area.all.each_with_index do |area, index|
        success_order_quantity = 20 # 支付订单数
        pending_order_quantity = 50 * (index + 1) - success_order_quantity # 未支付订单数，50是基数
        # 支付订单
        (1..success_order_quantity).each do |i|
          user = User.create(mobile: 13_800_000_000 + Random.rand(100_000_000 - 10_000_000))
          order = Order.create(user_id: user.id, city_id: city.id, city_name: city.name, stadium_id: stadium.id, stadium_name: stadium.name,
                               concert_id: concert.id, concert_name: concert.name, show_id: show.id, show_name: show.name, amount: i + 100,
                               tickets_count: 1, status: Order.statuses[:success])
          Ticket.create(area_id: area.id, show_id: show.id, order_id: order.id, price: 100, code: SecureRandom.hex(6),
                        status: Ticket.statuses[:success], seat_type: Ticket.seat_types[:locked])
        end
        # 未支付订单
        (1..pending_order_quantity).each do |i|
          user = User.create(mobile: 13_800_000_000 + Random.rand(100_000_000 - 10_000_000))
          order = Order.create(user_id: user.id, city_id: city.id, city_name: city.name, stadium_id: stadium.id, stadium_name: stadium.name,
                               concert_id: concert.id, concert_name: concert.name, show_id: show.id, show_name: show.name, amount: i + 100, tickets_count: 1)
          Ticket.create(area_id: area.id, show_id: show.id, order_id: order.id, price: 100, code: SecureRandom.hex(6),
                        status: Ticket.statuses[:pending], seat_type: Ticket.seat_types[:locked])
        end
        ## 减库存
        #ShowAreaRelation.where(show_id: show.id, area_id: area.id).first.decrement!(:left_seats, by = success_order_quantity + pending_order_quantity)
      end
    end
  end
end
