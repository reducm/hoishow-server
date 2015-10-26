@user ||= nil

json.array! @comments do |comment|
  json.(comment, :created_by, :likes_count, :content)
  json.created_at comment.created_at.to_ms
  json.avatar comment.creator_avatar || ''
  json.is_liked comment.is_liked(@user.try(:id))
  json.parent do
    parent = BoomComment.find_by_id(comment.parent_id)
    json.(parent, :id, :content, :created_by)
  end if comment.parent_id
end
