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
      end
    end
  end
rescue Exception => e
  ap $@
ensure
  file.close
end

city = City.first
stadium = Stadium.create(name: '首都体育馆', address: '北京市海淀区中关村南大街56号', city_id: city.id)

stars = ['Coldplay', 'Eminem', 'Jay-z', 'Maroon 5', 'Linkin Park']
img_url = 'coldplay.png'

# star, concert, star_concert_relation, show
stars.each do |star|
  star = Star.create(name: star, avatar: img_url)

  concert = Concert.create(name: "#{star.name}全球巡回演唱会", start_date: Time.now + 1.month, end_date: Time.now + 5.month, status: 0)
  StarConcertRelation.create(star_id: star.id, concert_id: concert.id)

  Show.create(name: "#{star.name}全球巡回演唱会#{city.name}站", show_time: Time.now + 2.month, min_price: 99, max_price: 1099, concert_id: concert.id, city_id: city.id, stadium_id: stadium.id)

  Topic.create(creator_type: 'Star', creator_id: star.id, city_id: city.id, content: '大家快来看演唱会', subject_type: 'Star', subject_id: star.id)
end

# area, show_area_relation
('a'..'e').to_a.each_with_index do |n, idx|
  area = Area.create(name: n, seats_count: 100, stadium_id: stadium.id)

  ShowAreaRelation.create(show_id: 1, area_id: area.id, price: idx + 100, seats_count: 100)
end

# admin
admin = Admin.create(name: 'admin', admin_type: 0)
admin.set_password('123')
admin.save

