json.stadium do
  json.partial! "api/v1/stadiums/stadium", stadium: @stadium, need_city: true
end
json.show do
  json.partial! "api/v1/shows/show", show: @show, need_concert: true, need_areas: true
end
