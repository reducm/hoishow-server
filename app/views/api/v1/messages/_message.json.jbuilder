json.(message, :title, :content)
json.subject_type message.subject_type || ''
json.subject_id message.subject_id || ''
json.created_at message.created_at.to_ms
json.creator do
  json.id message.creator_id || ''
  json.name message.creator_name || ''
  json.avatar message.creator.avatar_url || ''
  json.is_admin message.creator.is_a?(Admin) ? true : false
end
json.is_new message.has_new_send_log? 
