json.array! @collaborators do |colla|
  json.(colla, :id, :email, :contact, :weibo, :wechat, :description)
  json.name colla.display_name
  json.cover colla.cover_url || ''
end
