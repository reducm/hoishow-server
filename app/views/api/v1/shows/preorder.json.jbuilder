json.stadium do
  json.partial! "api/v1/stadiums/stadium", stadium: @stadium
  json.areas do
    json.array! @areas do|area|
      json.(area, :id, :name, :seats_count)
      json.price @relations.select{|r| r.area_id == area.id}.first.price
      json.seats_left @show.area_seats_left(area)
      json.is_sold_out  @show.area_is_sold_out(area)
    end
  end
end
json.show do
  json.partial! "api/v1/shows/show", show: @show
end
