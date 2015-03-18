json.array! @stars do |star|
  json.partial! "star", locals: {star: star, user: @user}
end
