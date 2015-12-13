namespace :boom_playlists do
  task :get_newest_cover => :environment do
    BoomPlaylist.where(is_default: 1).each do |pl|
      newest_track = pl.tracks.order('playlist_track_relations.created_at desc').first
      if newest_track
        pl.remote_cover_url = newest_track.current_cover_url
        pl.save
      end
    end
  end
end
