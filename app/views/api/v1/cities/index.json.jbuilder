json.array! @cities do |city|
  json.partial! "api/v1/cities/city", locals: {city: city}
end


