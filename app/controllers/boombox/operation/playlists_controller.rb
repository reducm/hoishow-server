# encoding: utf-8
class Boombox::Operation::PlaylistsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_playlist, except: [:search, :index, :new, :create]

  def index
    params[:playlists_page] ||= 1
    params[:playlists_per] ||= 10
    playlists = BoomPlaylist.valid_playlists

    if params[:playlists_start_time].present?
      playlists = playlists.where("created_at > '#{params[:playlists_start_time]}'")
    end

    if params[:playlists_end_time].present?
      playlists = playlists.where("created_at < '#{params[:playlists_end_time]}'")
    end

    if params[:playlists_is_top].present?
      playlists = playlists.where(is_top: params[:playlists_is_top])
    end

    if params[:playlists_q].present?
      playlists = playlists.where("name like ?", "%#{params[:playlists_q]}%")
    end

    @playlists = playlists.page(params[:playlists_page]).order("created_at desc").per(params[:playlists_per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def new
    @playlist = BoomPlaylist.new
    @tags = BoomTag.all
  end

  def create
    @playlist = BoomPlaylist.new(playlist_params)
    @playlist.creator_id = @current_admin.id
    @playlist.creator_type = BoomTrack::CREATOR_ADMIN
    @playlist.mode = 0
    if @playlist.save!
      if params[:boom_tag_ids].present?
        subject_relate_tag(params[:boom_tag_ids], @playlist)
      end
      flash[:notice] = '创建Playlist成功'
    else
      flash[:alert] = '创建Playlist失败'
    end
    redirect_to boombox_operation_playlists_url
  end

  def update
    if @playlist.update(playlist_params)
      if params[:boom_tag_ids].present?
        subject_relate_tag(params[:boom_tag_ids], @playlist)
      end
      flash[:notice] = '编辑Playlist成功'
    else
      flash[:alert] = '编辑Playlist失败'
    end
      redirect_to boombox_operation_playlists_url
  end

  def edit
    @tags = BoomTag.all
    @tags_already_added_ids = get_subject_tags(@playlist)
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
    pl_tracks = @playlist.tracks.where(removed: false)
    playlist_track_ids = pl_tracks.pluck(:id)
    @playlist_tracks = pl_tracks.page(params[:playlist_tracks_page]).order('is_top desc, created_at desc')
    total_tracks = BoomTrack.valid
    if playlist_track_ids.present?
      total_tracks = total_tracks.where("id not in (?)", playlist_track_ids)
    end
    @tracks =
      if params[:q].present?
        total_tracks.where("name like '%#{params[:q]}%'").page(params[:search_tracks_page])
      else
        total_tracks.page(params[:search_tracks_page])
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

  def publish
    if @playlist.update(is_display: 1)
      flash[:notice] = 'playlist发布成功'
    else
      flash[:error] = 'playlist发布失败'
    end

    redirect_to manage_tracks_boombox_operation_playlist_url(@playlist)
  end

  private
  def get_playlist
    @playlist = BoomPlaylist.find(params[:id])
  end

  def playlist_params
    params.require(:boom_playlist).permit(:cover, :name, :is_top)
  end
end
