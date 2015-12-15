# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'timeout'

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
        beatport_logger.info "--------------处理标签#{tag}, 时间:#{Time.now}--------------"
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
        beatport_logger.info "--------------处理完成Tag: #{tag}, 时间:#{Time.now}--------------"
        #end of tag
      end

      #保存到数据库
      #save_to_database
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
      start_time = Time.now
      beatport_logger.info "开始录入数据, 时间: #{start_time}"
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
                #更新playlist的封面
                if boom_playlist.cover_url.blank?
                  update_remote_url(boom_playlist, pl_cover_url, "cover")
                end

                #关联tag和playlist
                boom_playlist.tag_for_playlist(boom_tag)

                #创建track
                pl_tracks_array.each do |track_hash|
                  track_cover_url = track_hash["cover_url"]
                  track_file_url = track_hash["file_url"]
                  track_mp3_url_id = get_track_id(track_file_url)
                  track_name = track_hash["name"]
                  track_artists = track_hash["artists"]
                  track_tag = track_hash["tag"]
                  beatport_logger.info "开始创建Track: #{track_name}, 时间: #{Time.now}"
                  boom_track = create_track(track_name, creator_id, track_artists, track_mp3_url_id)
                  if boom_track
                    beatport_logger.info "创建Track: #{track_name}完成, 时间: #{Time.now}"
                    #                    update_remote_url(boom_track, track_file_url, "file")

                    #关联tag和track
                    if track_tag == tag_name
                      boom_track.tag_for_track(boom_tag)
                    else
                      new_tag = create_tag(track_tag)
                      if new_tag
                        boom_track.tag_for_track(new_tag)
                      else
                        beatport_logger.info "创建新标签: #{track_tag}失败, 时间: #{Time.now}"
                      end
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
          else
            beatport_logger.info "创建标签: #{tag_name}失败, 时间: #{Time.now}"
          end
        end
      ensure
        file.close unless file.closed?
      end
      end_time = ( Time.now - start_time ).to_i
      beatport_logger.info "录入数据完成, 时间: #{Time.now}, 历时#{ end_time }秒"
    end

    def create_tag(tag)
      BoomTag.where(name: tag, lower_string: tag.gsub(/\s/, "").downcase).first_or_create!
    end

    def create_playlist(name, creator_id)
      BoomPlaylist.where(name: name, mode: 0).first_or_create(creator_id: creator_id, creator_type:"BoomAdmin")
    end

    def create_track(name, creator_id, artists, track_mp3_url_id)
      BoomTrack.where(name: name).first_or_create(duration: 120, creator_id: creator_id, creator_type:"BoomAdmin", artists: artists, boom_id: track_mp3_url_id)
    end

    def update_remote_url(subject, url, type)
      subject_class = subject.class.to_s
      5.times do
        begin
          temp = nil
          if type == "cover"
            temp =
              Timeout::timeout(15) do
                subject.remote_cover_url = url 
                subject.save!
              end
          elsif type == "file"
            temp = 
              Timeout::timeout(200) do
                subject.remote_file_url = url  
                subject.save!
              end
          else
            beatport_logger.info "type参数不能识别, 对象为#{subject_class}, ID为#{subject.id}"
            return
          end

          if temp
            beatport_logger.info "更新#{subject_class}: #{subject.name}的#{type}_url成功"
            return
          else
            beatport_logger.info "转传#{subject_class}: #{subject.name}的#{type}_url出错, 即将重试, id为#{subject.id}"
            next
          end
        rescue Exception => e
          beatport_logger.info "转传#{subject_class}: #{subject.name}的#{type}_url出错, 即将重试, id为#{subject.id}"
          next
        end
      end
      beatport_logger.info "更新#{subject_class}: #{subject.name}的#{type}_url失败, id为#{subject.id}"
      nil
    end

    def request_url(url)
      10.times do
        begin
          temp = Timeout::timeout(10){ Nokogiri::HTML(open(url)) } rescue nil
          if temp
            return temp
          else
            beatport_logger.info "获取不到#{url}内容, 即将重试"
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

    def get_tracks_count
      tracks_count = []
      begin
        file = File.open("tmp/beatport_data.json", "r")
        file.each do |line|
          l = JSON.parse line
          temp = l.first
          playlists_array = temp[1]
          playlists_array.each do |playlist_hash|
            tracks_array = playlist_hash["tracks"]
            tracks_array.each do |track_hash|
              tracks_count.push(get_track_id(track_hash["file_url"]))
            end
          end
        end
      ensure
        file.close unless file.closed?
      end
      p "一共#{tracks_count.count}首，用mp3的id去重后为 #{tracks_count.uniq.count}首"
    end

    def get_playlists_count
      playlists_count = 0
      pl_tracks_link_array = []
      pl_name_array = []
      begin
        file = File.open("tmp/beatport_data.json", "r")
        file.each do |line|
          l = JSON.parse line
          temp = l.first
          playlists_array = temp[1]
          playlists_count += playlists_array.count
          playlists_array.each do |pl|
            pl_tracks_link_array.push(pl["tracks_link"])
            pl_name_array.push(pl["name"])
          end
        end
      ensure
        file.close unless file.closed?
      end
      p "一共#{playlists_count}个,用tracks_link去重后为#{pl_tracks_link_array.uniq.count}/#{pl_tracks_link_array.count}个,用name去重后为#{pl_name_array.uniq.count}/#{pl_name_array.count}个"
    end

    def get_track_id(url)
      url.split("/").last.split(".").first
    end

    def get_track_mp3_url
      begin
        file = File.open("tmp/beatport_data.json", "r")
        mp3_url_file = File.open("tmp/mp3_urls.json", "a")
        urls_array = []
        file.each do |line|
          l = JSON.parse line
          temp = l.first
          playlists_array = temp[1]
          playlists_array.each do |playlist_hash|
            tracks_array = playlist_hash["tracks"]
            tracks_array.each do |track_hash|
              urls_array.push(track_hash["file_url"])
            end
          end
        end
        uniq_urls = urls_array.uniq
        uniq_urls.each do |uniq_url|
          uniq_url[4] = ""
          mp3_url_file << uniq_url << "\n"
        end
      ensure
        file.close unless file.closed?
        mp3_url_file.close unless mp3_url_file.closed?
      end
    end

  end
end
