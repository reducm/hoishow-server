json.partial! "topic", { topic: @topic, user: @user } 
json.comments @topic.comments, partial: 'api/v1/comments/comment', as: :comment
