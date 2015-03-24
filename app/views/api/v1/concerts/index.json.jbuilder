json.array! @concerts do |concert|
  json.partial! "concert", locals: {concert: concert, user: @user}
end

