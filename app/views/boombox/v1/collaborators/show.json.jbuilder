@user ||= nil

json.(@collaborator, :id, :name, :email, :contact, :weibo, :wechat, :description, :followed_count)
json.is_followed @collaborator.is_followed(@user.try(:id))
json.cover @collaborator.cover_url || ''
json.albums do
  json.array! @collaborator.boom_albums do |album|
    json.image album.image_url || ''
  end
end
