user ||= false
json.(topic, :id, :content, :created_at, :is_top, :like_count, :subject_type, :subject_id)
json.city{ json.partial!("api/v1/cities/city", {city: topic.city}) }
json.creator do 
  json.name topic.creator_name 
  json.avatar topic.creator.avatar.url rescue nil
  json.is_admin topic.creator.is_a?(Admin) ? true : false
end
json.comments_count topic.comments.count
json.is_like topic.is_like(user)
