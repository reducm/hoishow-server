json.array! @areas do |area|
  json.partial! "api/v1/areas/area", locals: {area: area}
end
