json.(comment, :id, :subject_type, :subject_id, :content)
json.user  do
  json.id comment.user.id
  json.nickname comment.user.nickname
  json.avatar comment.user.avatar.url rescue nil
end