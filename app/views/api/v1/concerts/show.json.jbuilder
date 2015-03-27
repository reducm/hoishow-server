#json.partial! "concert", { concert: @concert, user: @user, need_stars: true, need_comments: true, need_shows: true  }
json.partial! "concert", { concert: @concert, user: @user } 
json.set! :cities, []
json.set! :stars, { need_stars: true }
json.set! :comments, { need_comments: true }
json.set! :shows, { need_shows: true }
