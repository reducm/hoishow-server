@user ||= nil
need_concerts ||= false
need_shows ||= false
need_topics ||= false

@followed_stars = @user.present? ? @user.follow_stars.pluck(:id) : []

json.(star, :id, :name, :position, :status_cn)
json.avatar star.avatar_url || ''
json.poster star.poster_url || ''
json.is_followed star.id.in?(@followed_stars)
json.followers_count star.followers_count

if star.videos.is_main.any? && star.videos.is_main.first.valid?
  json.video { json.partial!("api/v1/videos/video", { video: star.videos.is_main.first }) }
else
  json.video nil 
end

if need_concerts
  json.concerts{ json.array! star.concerts.showing_concerts, partial: "api/v1/concerts/concert", as: :concert }
end

if need_shows
  json.shows{ json.array! star.shows.is_display, partial: "api/v1/shows/show", as: :show }
end

if need_topics
  json.topics{ json.array! star.topics, partial: "api/v1/topics/topic", as: :topic }
end
