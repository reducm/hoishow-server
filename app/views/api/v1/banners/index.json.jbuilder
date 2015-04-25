json.array! @banners do |banner|
  json.partial! "banner", locals: {banner: banner}
end
