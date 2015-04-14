json.array! @comments do |comment|
  json.partial! "api/v1/comments/comment", locals: {comment: comment}
end


