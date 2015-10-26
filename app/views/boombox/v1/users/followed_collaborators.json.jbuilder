json.array! @collaborators do |collaborator|
  json.(collaborator, :id, :name, :email, :contact, :weibo, :wechat, :description)
  json.cover collaborator.cover_url || ''
end
