@user ||= nil

json.array! @topics do |topic|
  json.(topic, :id, :created_by, :subject_id, :subject_type, :likes_count, :comments_count)
  json.created_at topic.created_at.to_ms || ''
  json.avatar topic.creator_avatar || ''
  json.content topic.content
  json.is_liked topic.is_liked(@user.try(:id))
end
