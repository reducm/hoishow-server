# encoding: utf-8
class Boombox::Operation::PlaylistsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_playlist, except: [:search, :index, :new, :create]

  def index
    params[:playlists_page] ||= 1
    params[:per] ||= 10
    playlists = BoomPlaylist.valid_playlists

    if params[:start_time].present?
      playlists = playlists.where("created_at > '#{params[:start_time]}'")
    end

    if params[:end_time].present?
      playlists = playlists.where("created_at < '#{params[:end_time]}'")
    end

    if params[:is_top].present?
      playlists = playlists.where(is_top: params[:is_top])
    end

    if params[:q].present?
      playlists = playlists.where("name like '%#{params[:q]}%'")
    end

    @playlists = playlists.page(params[:playlists_page]).order("created_at desc").per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def new
    @playlist = BoomPlaylist.new
  end

  def create
    @playlist = BoomPlaylist.new(playlist_params)
    @playlist.creator_id = @current_admin.id
    @playlist.creator_type = BoomTrack::CREATOR_ADMIN
    @playlist.mode = 0
    if @playlist.save!
      BoomTag.where('id in (?)', params[:tag_ids].split(',')).each{ |tag| @playlist.tag_for_playlist(tag) }
      flash[:notice] = '创建Playlist成功'
      redirect_to boombox_operation_playlists_url
    end
  end

  def update
    if @playlist.update(playlist_params)
      target_tag_ids = params[:tag_ids]
      if target_tag_ids
        target_tag_ids = target_tag_ids.split(",").map{|target| target.to_i}
        source_tag_ids = @playlist.boom_tags.pluck(:id)
        #关联新tag，删除多余的tag
        new_tag_ids = target_tag_ids - source_tag_ids
        if new_tag_ids.present?
          BoomTag.where('id in (?)', new_tag_ids).each{ |tag| @playlist.tag_for_playlist(tag) }
        end
        del_tag_ids = source_tag_ids - target_tag_ids 
        if del_tag_ids.present?
          @playlist.tag_subject_relations.where('boom_tag_id in (?)', del_tag_ids).each{ |del_tag| del_tag.destroy! }
        end
      end
      flash[:notice] = '编辑Playlist成功'
      redirect_to boombox_operation_playlists_url
    end
  end

  def edit
  end

  def destroy
    @playlist.destroy!
    redirect_to action: :index
  end

  def change_is_top
    if @playlist.is_top
      @playlist.update(is_top: false)
      flash[:notice] = "取消推荐成功"
    else
      @playlist.update(is_top: true)
      flash[:notice] = "更新推荐成功"
    end
    redirect_to boombox_operation_playlists_url
  end

  def manage_tracks
    @playlist_tracks = @playlist.tracks.valid.page(params[:tracks_page])
    if params[:q].present?
      @tracks = BoomTrack.valid.where("name like '%#{params[:q]}%'").page(params[:tracks_page])
    else
      @tracks = BoomTrack.valid.page(params[:tracks_page])
    end
  end

  def add_track
    @playlist.playlist_track_relations.where(boom_track_id: params[:track_id]).first_or_create!
    render json: { success: true }
  end

  def remove_track
    relation = @playlist.playlist_track_relations.where(boom_track_id: params[:track_id]).first
    if relation
      relation.destroy!
      render json: { success: true }
    end
  end
  
  private
  def get_playlist
    @playlist = BoomPlaylist.find(params[:id])
  end

  def playlist_params
    params.require(:boom_playlist).permit(:cover, :name, :is_top)
  end
end
