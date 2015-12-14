# encoding: utf-8
class Boombox::Dj::BoomTracksController < Boombox::Dj::ApplicationController
  before_filter :check_login!
  before_filter :get_track, except: [:search, :index, :new, :create]

  def index
    @tracks = current_collaborator.boom_tracks 
    @tracks = @tracks.valid.page(params[:tracks_page]).order("created_at desc")
  end

  def search
    tracks = current_collaborator.boom_tracks.valid
    if params[:q].present?
      tracks = tracks.where("name like ?", "%#{params[:q]}%")
    end
    tracks = tracks.where("created_at > ? and created_at < ?", params[:start_time], params[:end_time])
    @tracks = tracks.order("created_at desc").page(params[:page])
    render :index
  end

  def new
    @tags = BoomTag.all
    @track = current_collaborator.boom_tracks.new
    get_all_artists
  end

  def create
    @track = current_collaborator.boom_tracks.new(track_params)
    if @track.save
      if params[:boom_tag_ids].present?
        @track.create_or_update_tag_relations(params[:boom_tag_ids])
      end
      if params[:boom_track][:artists].present?
        @track.create_tag_using_artists(params[:boom_track][:artists])
      end
      flash[:notice] = '创建音乐成功'
      redirect_to boombox_dj_boom_tracks_url
    else
      flash[:alert] = @track.errors.full_messages 
      @track = current_collaborator.boom_tracks.new
      render :new
    end
  end

  def update
    if @track.update(track_params)
      if params[:boom_tag_ids].present?
        @track.create_or_update_tag_relations(params[:boom_tag_ids])
      end
      if params[:boom_track][:artists].present?
        @track.create_tag_using_artists(params[:boom_track][:artists])
      end
      flash[:notice] = '编辑音乐成功'
      redirect_to boombox_dj_boom_tracks_url
    end
  end

  def edit
    @tags = BoomTag.all
    get_tags_already_added
    get_all_artists
  end

  def destroy
    if @track.destroy!
      flash[:notice] = '删除音乐成功'
    else
      flash[:alert] = @track.errors.full_messages
    end
    redirect_to boombox_dj_boom_tracks_url
  end

  private

  def get_all_artists
    artist_names = []
    BoomTrack.all.each do |track|
      if track.artists.present?
        artist_names << track.artists.split(',')
      end
    end
    @artist_names = artist_names.flatten.uniq
  end

  def get_tags_already_added
    if @track.boom_tags.any?
      @tags_already_added_ids = @track.boom_tags.pluck(:id)
    else
      @tags_already_added_ids = []
    end
  end

  def get_track
    @track = BoomTrack.find(params[:id])
  end

  def track_params
    params.require(:boom_track).permit(:cover, :name, :is_top, :file, :artists, :duration)
  end
end
