json.(comment, :id, :topic_id, :parent_id, :content )
comment_topic = comment.topic
comment_topic ? ( json.topic { json.partial!("api/v1/topics/topic", {topic: comment_topic})  } ) : (json.topic "")
parent_comment = Comment.where(id: comment.parent_id).first
parent_comment ? ( json.parent_comment { json.partial!("api/v1/comments/comment", {comment: parent_comment}) } ) : (json.parent_comment "")
json.creator do
  json.id comment.creator_id
  json.name comment.creator_name
  json.avatar comment.creator.avatar.url rescue ''
  json.is_admin comment.creator.is_a?(Admin) ? true : false
end
