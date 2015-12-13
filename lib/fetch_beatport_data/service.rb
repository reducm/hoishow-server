# coding: utf-8
require 'nokogiri'
require 'open-uri'

module FetchBeatportData
  module Service
    extend BeatportLogger
    extend self

    def fetch_data
      url = "https://pro.beatport.com/"
      home_doc = request_url(url)
      return if home_doc.blank?

      tag_hash = {}
      #爬tags
      home_doc.css("body ul.genre-drop-list-col-one li a").each do |e|
        tag_hash[e.content] = e["href"]
      end

      tags_array = tag_hash.keys
      tag_playlist_hash = {}
      playlists_data = []
      tracks_data = []

      tags_array.each do |tag|
        beatport_logger.info "处理标签#{tag}, 时间:#{Time.now}"
        #爬release，控制每页的数量,暂定为25,约5000首
        releases_link = url + tag_hash[tag] + "/releases?per-page=25"
        releases_doc = request_url(releases_link)
        next if releases_doc.blank?

        releases_doc.css("li.bucket-item.horz-release").each do |release|
          cover_url = release.css("img.horz-release-artwork").first["data-src"]
          playlist_infos = release.css("p.buk-horz-release-title a").first
          name = playlist_infos.content
          beatport_logger.info "处理playlist:#{name}, 时间: #{ Time.now }"
          #爬tracks
          tracks_link = url + playlist_infos["href"]

          release_tracks_doc = request_url(tracks_link)
          next if release_tracks_doc.blank?

          release_tracks_doc.css(".buk-track-meta-parent").map do |track|
            track_id = track.css(".buk-track-title a").first["href"].split("/").last
            track_url = "https://geo-samples.beatport.com/lofi/#{track_id}.LOFI.mp3"
            track_name = track.css(".buk-track-title span").map(&:content).join(" ")
            track_artists = track.css(".buk-track-artists a").map(&:content).join(",")
            track_tag = track.css(".buk-track-genre a").first.content
            beatport_logger.info "处理Track: #{track_name}, 时间:#{Time.now}"
            tracks_data.push({cover_url: cover_url, file_url: track_url, name: track_name, artists: track_artists, tag: track_tag})
            # end of track
          end

          playlists_data.push({name: name, cover: cover_url, tracks_link: tracks_link, tracks: tracks_data})
          tracks_data = []
          beatport_logger.info "处理完成Plalyist: #{name}, 时间:#{Time.now}"
          #end of playlist
        end

        if playlists_data
          tag_playlist_hash[tag] = playlists_data
          tag_playlist_hash["releases_link"] = releases_link
          save_to_file(tag_playlist_hash)
        end

        playlists_data = []
        tag_playlist_hash = {}
        beatport_logger.info "处理完成Tag: #{tag}, 时间:#{Time.now}"
        #end of tag
      end

      #保存到数据库
      beatport_logger.info "开始录入数据, 时间: #{Time.now}"
      save_to_database
      beatport_logger.info "录入数据完成, 时间: #{Time.now}"
    end

    def save_to_file(data)
      file = File.open("tmp/beatport_data.json","a")
      begin
        file << data.to_json << "\n"
      ensure
        file.close unless file.closed?
      end
    end

    def save_to_database
      creator_id = BoomAdmin.first.id
      file = File.open("tmp/beatport_data.json", "r")
      begin
        file.each do |line|
          bp_data = JSON.parse line
          temp_data = bp_data.first

          #创建tag
          tag_name = temp_data[0]
          beatport_logger.info "开始创建标签: #{tag_name}, 时间: #{Time.now}"
          boom_tag = create_tag(tag_name)
          if boom_tag
            beatport_logger.info "创建标签: #{tag_name}完成, 时间: #{Time.now}"
          else
            beatport_logger.info "创建标签: #{tag_name}失败, 时间: #{Time.now}"
          end

          #创建playlist
          playlists_array = temp_data[1]
          playlists_array.each do |pl|
            pl_name = pl["name"]
            pl_cover_url = pl["cover"]
            pl_tracks_array = pl["tracks"]
            beatport_logger.info "开始创建Playlist: #{pl_name}, 时间: #{Time.now}"
            boom_playlist = create_playlist(pl_name, creator_id)
            if boom_playlist
              beatport_logger.info "创建Playlist: #{pl_name}完成, 时间: #{Time.now}"
              update_playlist_cover_url(boom_playlist, pl_cover_url)
              #关联tag和playlist
              boom_playlist.tag_for_playlist(boom_tag)

              #创建track
              pl_tracks_array.each do |track_hash|
                track_cover_url = boom_playlist.cover_url
                track_file_url = track_hash["file_url"]
                track_name = track_hash["name"]
                track_artists = track_hash["artists"]
                track_tag = track_hash["tag"]
                track_url_id = track_file_url.split("/").last.split(".").first
                beatport_logger.info track_tag
                beatport_logger.info "开始创建Track: #{track_name}, 时间: #{Time.now}"
                boom_track = create_track(track_name, creator_id, track_artists, track_url_id)
                if boom_track
                  beatport_logger.info "创建Track: #{track_name}完成, 时间: #{Time.now}"
                  # update_track_file_url(boom_track, track_file_url)

                  #关联tag和track
                  if track_tag == tag_name
                    boom_track.tag_for_track(boom_tag)
                  else
                    new_tag = create_tag(track_tag)
                    boom_track.tag_for_track(new_tag)
                  end

                  #关联playlist和track
                  boom_playlist.playlist_track_relations.where(boom_track_id: boom_track.id).first_or_create!
                else
                  beatport_logger.info "创建Track: #{track_name}失败, 时间: #{Time.now}"
                end

              end
            else
              beatport_logger.info "创建Playlist: #{pl_name}失败, 时间: #{Time.now}"
            end
          end
        end
      ensure
        file.close unless file.closed?
      end
    end

    def create_tag(tag)
      BoomTag.where(name: tag, lower_string: tag.gsub(/\s/, "").downcase).first_or_create!
    end

    def create_playlist(name, creator_id)
      BoomPlaylist.where(name: name).first_or_create!(creator_id: creator_id, creator_type:"BoomAdmin", mode: 0)
    end

    def create_track(name, creator_id, artists, track_url_id)
      BoomTrack.where(name: name).first_or_create(duration: 120,  creator_id: creator_id, creator_type:"BoomAdmin", artists: artists, boom_id: track_url_id, fetch_cover_url: track_cover_url)
    end

    def update_playlist_cover_url(playlist, url)
      5.times do
        begin
          playlist.remote_cover_url = url
          if playlist.save!
            beatport_logger.info "更新Playlist: #{playlist.name}的cover_url成功"
            return
          end
        rescue Exception => e
          beatport_logger.info "转传Playlist: #{playlist.name}出错, 即将重试, id为#{playlist.id}"
          next
        end
      end
      beatport_logger.info "更新Playlist: #{playlist.name}的cover_url失败"
      nil
    end

    def update_track_file_url(track, file_url)
      5.times do
        begin
          track.remote_file_url = file_url
          if track.save!
            beatport_logger.info "更新Track: #{track.name}的file_url成功"
            return
          end
        rescue Exception => e
          beatport_logger.info "转传Track: #{track.name}的file_url时出错, 即将重试, id为#{track.id}"
          next
        end
      end
      beatport_logger.info "更新Track: #{track.name}的file_url失败"
      nil
    end

    def request_url(url)
      10.times do
        begin
          temp = Nokogiri::HTML(open(url))
          if temp
            return temp
          else
            next
          end
        rescue Exception => e
          beatport_logger.info "即将重试, 错误信息: #{e}, 重试url为: #{url}"
          next
        end
      end
      beatport_logger.info "获取#{url}内容失败"
      nil
    end

    #本地测试专用
    def clean_data
      BoomTag.destroy_all
      BoomPlaylist.destroy_all
      BoomTrack.destroy_all
    end
  end
end
