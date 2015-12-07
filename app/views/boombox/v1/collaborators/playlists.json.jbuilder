@user ||= nil

json.array! @playlists, partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user, need_track_ids: true
