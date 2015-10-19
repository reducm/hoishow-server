json.id comment.id
json.content comment.content
json.created_by comment.created_by
json.created_at comment.created_at.to_ms rescue ''
json.avatar comment.creator_avatar || ''
if comment.parent_id
  json.parent do
    parent_comment = BoomComment.where(id: comment.parent_id).first
    json.id parent_comment.id
    json.content parent_comment.content
    json.created_by parent_comment.created_by
  end
else
  json.parent ""
end
