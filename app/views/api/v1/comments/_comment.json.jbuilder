json.(comment, :id, :topic_id, :content, :parent_id)
json.creator do
  json.id comment.creator_id
  json.name comment.creator_name
  json.avatar comment.creator.avatar.url || ''
  json.is_admin comment.creator.is_a?(Admin) ? true : false
end