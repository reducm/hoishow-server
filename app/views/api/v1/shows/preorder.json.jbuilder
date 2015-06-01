# encoding: utf-8
json.stadium do
  json.partial! "api/v1/stadiums/stadium", stadium: @stadium, show: @show, need_areas: true, need_city: true
end
json.show do
  json.partial! "api/v1/shows/show", show: @show, need_concert: true
end
