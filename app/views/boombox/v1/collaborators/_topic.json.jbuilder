json.(topic, :id, :likes_count, :comments_count)
json.created_by topic.created_by || ''
json.subject_id topic.subject_id || 0
json.subject_type topic.subject_type || ''
json.created_at topic.created_at.to_ms || ''
json.avatar topic.creator_avatar || ''
json.images do
  json.array! topic.attachments do |attachment|
    json.image attachment.image_url || ''
  end
end
json.video do
  json.title topic.video_title || ''
  json.url topic.video_url || ''
end
json.content topic.content
json.is_liked topic.is_liked(user.try(:id))
