json.array! @messages do |message|
  json.(message, :id, :subject_id, :subject_type, :content)
  json.created_by message.boom_admin.default_name
  json.created_at message.created_at.to_ms || ''
  json.avatar message.boom_admin.avatar_url
  if message.subject && message.subject_type == 'BoomActivity' && message.subject.activity?
    json.title message.subject_name
    json.description description_boombox_v1_activity_url(message.subject)
  end
end
