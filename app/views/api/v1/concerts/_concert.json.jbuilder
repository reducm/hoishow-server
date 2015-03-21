need_stars ||= false
need_comments ||= false

json.(concert, :id, :name, :description, :followers_count, :comments_count, :shows_count)

json.start_date concert.start_date.to_ms
json.end_date concert.end_date.to_ms
json.poster concert.poster.url rescue nil

if need_stars
  json.array! concert.stars, "api/v1/stars/star", as: star
end

if need_comments
  json.array! concert.comments, "api/v1/comments/comment", as: comment
end
