json.partial! "star", { star: @star, user: @user }

json.concerts do
  json.array! @star.concerts, partial: 'api/v1/concerts/concert', as: :concert
end

json.comments do
  json.array! @star.comments, partial: 'api/v1/comments/comment', as: :comment
end


json.shows do
  json.array! @star.shows, partial: 'api/v1/shows/show', as: :show
end
json.videos []
