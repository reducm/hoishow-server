json.array! @stars do |star|
  json.partial! "api/v1/stars/star", locals: {star: star, user: @user}
end
