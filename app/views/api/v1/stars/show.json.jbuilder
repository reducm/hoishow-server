json.partial! "star", { star: @star, user: @user }

json.concerts do
  json.array! @star.concerts, partial: 'api/v1/concerts/concert', as: :concert
end

json.shows do
  json.array! @star.shows, partial: 'api/v1/shows/show', as: :show
end
json.videos []
