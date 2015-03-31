# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)




city = JSON.parse(File.open("/Users/tangwenjie/projects/hoishow-server/db/city_district.json","r").read)

num = 0
city_count = city.count


while (num < city_count) do
  City.where(name: city[num]["name"]).first_or_initialize.update_attributes!(pinyin: city[num]["pinyin"], code: city[num]["code"], is_hot: city[num]["hot"] || false)

  district_array = city[num]["districts"]
  district_array_count = district_array.count
  i = 0
  while(i < district_array_count) do
    District.where(name: district_array[i]["name"]).first_or_initialize.update_attributes!(city_id: district_array[i]["city_id"])
    i += 1
  end

  num += 1

end
