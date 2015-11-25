@user ||= nil

json.(@collaborator, :id, :email, :contact, :weibo, :wechat, :description, :followed_count, :identity)
json.name @collaborator.display_name
json.is_followed @collaborator.is_followed(@user.try(:id))
json.cover @collaborator.cover_url || ''
json.albums do
  json.array! @collaborator.boom_albums do |album|
    json.image album.image_url || ''
  end
end
