# encoding: utf-8
class Boombox::Dj::PlaylistsController < Boombox::Dj::ApplicationController
  before_filter :check_login!
  before_filter :get_playlist, except: [:search, :index, :new, :create]

  def index
    @playlists = current_collaborator.boom_playlists 
    @playlists = @playlists.valid_playlists.page(params[:playlists_page]).order("created_at desc")
  end

  def search
    if params[:select_options] == "1"
      is_hot = true
    end
    if params[:q].present?
      @playlists = BoomPlaylist.valid_playlists.where("created_at > ? and created_at < ? and is_top = ?", params[:start_time], params[:end_time], is_hot).where("name like ?", "%#{params[:q]}%").page(params[:page]).order("created_at desc")
    elsif is_hot
      @playlists = BoomPlaylist.valid_playlists.where("created_at > ? and created_at < ? and is_top = ?", params[:start_time], params[:end_time], is_hot).page(params[:page]).order("created_at desc")
    else
      @playlists = BoomPlaylist.valid_playlists.where("created_at > ? and created_at < ?", params[:start_time], params[:end_time]).page(params[:page]).order("created_at desc")
    end
    render :index
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
      redirect_to boombox_dj_playlists_url(collaborator_id: current_collaborator.id)
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
      redirect_to boombox_dj_playlists_url(collaborator_id: current_collaborator.id)
    end
  end

  def edit
  end

  def destroy
    @playlist.destroy!
    redirect_to boombox_dj_playlists_url(collaborator_id: current_collaborator.id)
  end

  def change_is_top
    if @playlist.is_top
      @playlist.update(is_top: false)
      flash[:notice] = "取消推荐成功"
    else
      @playlist.update(is_top: true)
      flash[:notice] = "更新推荐成功"
    end
    redirect_to boombox_dj_playlists_url(collaborator_id: current_collaborator.id)
  end

  def manage_tracks
    @playlist_tracks = @playlist.tracks.valid.page(params[:tracks_page]).order("created_at desc")
    @tracks = BoomTrack.valid.page(params[:tracks_page]).order("created_at desc")
  end

  private
  def get_playlist
    @playlist = BoomPlaylist.find(params[:id])
  end

  def playlist_params
    params.require(:boom_playlist).permit(:cover, :name, :is_top)
  end
end
