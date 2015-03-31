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

          districts = city_json["districts"]
          District.transaction do
            districts.each do |district_json|
              district = city.districts.where(name: district_json["name"]).first_or_create!
            end
          end
        end
      end
    end
  end
rescue Exception => e
  ap $@
ensure
  file.close
end
