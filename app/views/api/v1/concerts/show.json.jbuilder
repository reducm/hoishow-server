json.partial! "concert", { concert: @concert, user: @user  }

json.stars do
  json.array! @concert.stars, partial: 'api/v1/stars/star', as: :star
end

json.comments do
  json.array! @concert.comments, partial: 'api/v1/comments/comment', as: :comment
end

json.shows do
  json.array! @concert.shows, partial: 'api/v1/shows/show', as: :show
end

json.cities []
