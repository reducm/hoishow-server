# encoding: utf-8
need_city ||= false
need_areas ||= false

json.(stadium, :id, :name, :address, :longitude, :latitude)

if need_city
  json.city { json.partial!("api/v1/cities/city", {city: stadium.city}) }
end

json.pic stadium.pic_url || ""

if need_areas
  json.areas stadium.areas do |area|
    json.partial! "api/v1/areas/area", show: show, area: area
  end
end

