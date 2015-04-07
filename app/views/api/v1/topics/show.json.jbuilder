json.partial! "topic", { topic: @topic } 
json.comments @topic.comments, partial: 'api/v1/comments/comment', as: :comment
