json.(message, :title, :content, :subject_type, :subject_id)
json.creator do
  json.id message.creator_id
  json.name message.creator_name
  json.avatar message.creator.avatar_url || ''
  json.is_admin message.creator.is_a?(Admin) ? true : false
end
