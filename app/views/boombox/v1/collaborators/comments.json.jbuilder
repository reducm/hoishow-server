@user ||= nil

json.partial! 'topic', topic: @topic, user: @user

json.comments do
  json.array! @comments do |comment|
    json.(comment, :id, :created_by, :likes_count)
    json.content comment.reply_content || ''
    json.created_at comment.created_at.to_ms || ''
    json.avatar comment.creator_avatar || ''
    json.is_liked comment.is_liked(@user.try(:id))
    if comment.parent_id
      json.parent do
        parent = BoomComment.where(id: comment.parent_id).first
        json.id parent.id
        json.content parent.reply_content || ''
        json.created_by parent.created_by || ''
      end
    else
      json.parent nil
    end
  end
end
