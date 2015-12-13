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
  end

  def create
    @playlist = current_collaborator.boom_playlists.new(playlist_params)
    @playlist.mode = 0
    if @playlist.save!
      BoomTag.where('id in (?)', params[:tag_ids].split(',')).each{ |tag| @playlist.tag_for_playlist(tag) }
      flash[:notice] = '创建Playlist成功'
      redirect_to boombox_dj_playlists_url
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
      redirect_to boombox_dj_playlists_url
    end
  end

  def edit
  end

  def destroy
    @playlist.destroy!
    redirect_to boombox_dj_playlists_url
  end

  def manage_tracks
    @playlist_tracks = @playlist.tracks.valid.page(params[:tracks_page])
    tracks = current_collaborator.boom_tracks.valid
    if params[:q].present?
      tracks = tracks.where("name like '%#{params[:q]}%'")
    end
    @tracks = tracks.page(params[:tracks_page])
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