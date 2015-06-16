@user ||= nil

json.(topic, :id, :is_top, :like_count, :subject_type, :subject_id)
json.content Base64.decode64(topic.content).force_encoding("utf-8")
json.created_at topic.created_at.to_ms
topic_city = topic.city
topic_city ? (json.city { json.partial!("api/v1/cities/city", {city: topic_city}) }) : (json.city nil)
json.creator do
  json.id topic.creator_id
  json.name topic.creator_name
  json.avatar topic.creator.avatar_url || ''
  json.is_admin topic.creator.is_a?(Admin)
  json.is_star topic.creator.is_a?(Star)
end
json.comments_count topic.comments.count
json.city_name @user ? topic.get_user_voted_city_name(@user) : ''
json.is_like topic.is_like(@user)
json.comments topic.comments.page(params[:page]), partial: 'api/v1/comments/comment', as: :comment
