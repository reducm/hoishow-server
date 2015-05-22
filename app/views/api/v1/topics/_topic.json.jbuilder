@user ||= nil

json.(topic, :id, :content, :is_top, :like_count, :subject_type, :subject_id)
json.created_at topic.created_at.to_ms
topic_city = topic.city
topic_city ? (json.city { json.partial!("api/v1/cities/city", {city: topic_city}) }) : (json.city nil)
json.creator do
  json.id topic.creator_id
  json.name topic.creator_name
  json.avatar topic.creator.avatar_url || ''
  json.is_admin topic.creator.is_a?(Admin) ? true : false
end
json.comments_count topic.comments.count
json.is_like topic.is_like(@user)
json.comments topic.comments, partial: 'api/v1/comments/comment', as: :comment