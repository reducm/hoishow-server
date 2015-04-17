user ||= false
json.(topic, :id, :content, :is_top, :like_count, :subject_type, :subject_id)
json.created_at topic.created_at.to_ms
json.city{ json.partial!("api/v1/cities/city", {city: topic.city}) } if topic.city.present?
json.creator do
  json.name topic.creator_name
  json.avatar topic.creator.avatar.url || ''
  json.is_admin topic.creator.is_a?(Admin) ? true : false
end
json.comments_count topic.comments.count
json.is_like topic.is_like(user)
