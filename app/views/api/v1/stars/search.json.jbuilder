json.array! @stars do |star|
  json.partial! "star", locals: {star: star}
end
