user ||= nil
need_concerts ||= false
need_shows ||= false
need_topics ||= false

@followed_stars = user.present? ? user.follow_stars.pluck(:id) : []

json.(star, :id, :name)
json.avatar star.avatar.url rescue nil 
json.is_followed star.id.in?(@followed_stars) ? true : false

if need_concerts
  json.concerts{ json.array! star.concerts, partial: "api/v1/concerts/concert", as: :concert, user: @user }
end

if need_shows
  json.shows{ json.array! star.shows, partial: "api/v1/shows/show", as: :show, user: @user }
end

if need_topics
  json.topics{ json.array! star.topics, partial: "api/v1/topics/topic", as: :topic, user: @user }
end



