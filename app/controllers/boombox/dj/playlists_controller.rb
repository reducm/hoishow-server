# encoding: utf-8
class Boombox::Dj::PlaylistsController < Boombox::Dj::ApplicationController
  before_filter :check_login!
  before_filter :get_playlist, except: [:search, :index, :new, :create]

  def index
    @playlists = current_collaborator.boom_playlists 
    @playlists = @playlists.valid_playlists.page(params[:playlists_page]).order("created_at desc")
  end

  def search
    playlists = current_collaborator.boom_playlists.valid_playlists
    if params[:q].present?
      playlists = playlists.where("name like ?", "%#{params[:q]}%")
    end
    playlists = playlists.where("created_at > ? and created_at < ?", params[:start_time], params[:end_time])
    @playlists = playlists.order("created_at desc").page(params[:page])
    render :index
  end

  def new
    @playlist = BoomPlaylist.new
    @tags = BoomTag.all
  end

  def create
    @playlist = current_collaborator.boom_playlists.new(playlist_params)
    @playlist.creator_id = current_collaborator.id
    @playlist.creator_type = BoomPlaylist::CREATOR_COLLABORATOR
    @playlist.mode = 0
    if @playlist.save!
      if params[:boom_tag_ids].present?
        subject_relate_tag(params[:boom_tag_ids], @playlist)
      end
      flash[:notice] = '创建Playlist成功'
    else
      flash[:alert] = '创建Playlist失败'
    end
    redirect_to boombox_dj_playlists_url
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
      redirect_to boombox_dj_playlists_url
  end

  def edit
    @tags = BoomTag.all
    @tags_already_added_ids = get_subject_tags(@playlist)
  end

  def destroy
    @playlist.destroy!
    redirect_to boombox_dj_playlists_url
  end

  def manage_tracks
    get_manage_tracks

    respond_to do |format|
      format.html
      format.js
    end
  end

  def add_track
    @playlist.playlist_track_relations.where(boom_track_id: params[:track_id]).first_or_create!

    get_manage_tracks
    respond_to do |format|
      format.js
    end
  end

  def remove_track
    relation = @playlist.playlist_track_relations.where(boom_track_id: params[:track_id]).first
    if relation
      relation.destroy!
    end

    get_manage_tracks
    respond_to do |format|
      format.js
    end
  end

  private
  def get_playlist
    @playlist = BoomPlaylist.find(params[:id])
  end

  def playlist_params
    params.require(:boom_playlist).permit(:cover, :name, :is_top)
  end

  def get_manage_tracks
    @playlist_tracks = @playlist.tracks.valid.page(params[:playlist_tracks_page])
    tracks = current_collaborator.boom_tracks.valid.where.not(id: @playlist.tracks.valid.ids)
    if params[:q].present?
      tracks = tracks.where("name like '%#{params[:q]}%'")
    end
    @tracks = tracks.page(params[:search_tracks_page])
  end
end
