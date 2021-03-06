json.(comment, :id, :topic_id)
json.created_at comment.created_at.to_ms
json.content Base64.decode64(comment.content).force_encoding("utf-8")
json.parent_id comment.parent_id || ''
parent_comment = Comment.where(id: comment.parent_id).first
parent_comment ? ( json.parent_comment { json.partial!("api/v1/comments/comment", {comment: parent_comment}) } ) : (json.parent_comment nil)
json.creator do
  json.id comment.creator_id
  json.name comment.creator_name
  json.avatar comment.creator.avatar_url rescue ''
  json.is_admin comment.creator.is_a?(Admin)
  json.is_star comment.creator.is_a?(Star)
end
