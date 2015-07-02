json.(message, :title, :content)
json.subject_type message.subject_type || ''
json.subject_id message.subject_id || ''
json.created_at message.created_at.to_ms
if message.creator_type == 'All'
  json.creator do
    json.id ''
    json.name 'hoishow官方'
    json.avatar "#{UpyunSetting["upyun_upload_url"]}/admin_avatar.png"
    json.is_admin true
  end
else
  json.creator do
    json.id message.creator_id || ''
    json.name message.creator_name || ''
    json.avatar message.creator.avatar_url || ''
    json.is_admin message.creator.is_a?(Admin)
  end
end
json.is_new message.has_new_send_log?
