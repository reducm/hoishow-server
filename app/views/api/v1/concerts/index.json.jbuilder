json.array! @concerts do |concert|
  json.partial! "api/v1/concerts/concert", locals: {concert: concert, user: @user}
end

#json.array! @shows do |show|
 # json.partial! "api/v1/shows/show", locals: {show: show, user: @user}
#end

