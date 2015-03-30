json.array! @concerts do |concert|
  json.partial! "api/v1/concerts/concert", locals: {concert: concert, user: @user}
end


