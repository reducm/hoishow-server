@followed_stars = user.present? ? user.stars.pluck(:id) : []

json.(star, :id, :name)
json.avatar star.avatar.url rescue nil 
json.is_followed star.id.in?(@followed_stars) ? true : false
