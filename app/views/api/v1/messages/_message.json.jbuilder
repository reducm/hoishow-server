json.(message, :title, :content)
json.redirect_url url_for([:api, :v1, message.subject])
json.creator do
  json.id message.creator_id
  json.name message.creator_name
  json.avatar message.creator.avatar_url || ''
  json.is_admin message.creator.is_a?(Admin) ? true : false
end
