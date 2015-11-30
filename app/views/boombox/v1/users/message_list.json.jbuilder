json.array! @messages do |message|
  json.(message, :id, :subject_id, :subject_type, :content)
  json.created_by BoomAdmin.first.default_name
  json.created_at message.created_at.to_ms || ''
  json.avatar BoomAdmin.first.avatar_url
  if message.subject && message.subject_type == 'BoomActivity' && message.subject.activity?
    json.title message.subject_name
    json.description description_boombox_v1_activity_url(message.subject)
  end
end
