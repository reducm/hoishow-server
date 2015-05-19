json.array! @topics do |topic|
  json.partial! "api/v1/topics/topic", locals: {topic: topic, user: @user}
end


