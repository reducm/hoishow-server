json.array! @stadiums do |stadium|
  json.partial! "api/v1/stadiums/stadium", locals: {stadium: stadium}
end


