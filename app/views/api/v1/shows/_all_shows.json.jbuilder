json.array! @shows do |show|
  json.partial! "api/v1/shows/show", locals: {show: show, user: @user}
end


