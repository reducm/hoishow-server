# encoding: utf-8
class Boombox::Dj::TracksController < Boombox::Dj::ApplicationController
  before_filter :check_login!
  before_filter :get_track, except: [:search, :index, :new, :create]

  def index
    @tracks = current_collaborator.boom_tracks 
    @tracks = @tracks.order("created_at desc").page(params[:tracks_page])
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
    @tag_names = get_all_tag_names
    @track = current_collaborator.boom_tracks.new
    get_all_track_artists
  end

  def create
    @track = current_collaborator.boom_tracks.new(track_params)
    @track.creator_id = current_collaborator.id
    @track.creator_type = BoomTrack::CREATOR_COLLABORATOR
    if @track.save
      if params[:boom_track][:track_tag_names].present?
        subject_relate_tag(params[:boom_track][:track_tag_names], @track)
      end
      if params[:boom_track][:artists].present?
        subject_relate_tag(params[:boom_track][:artists], @track, false)
      end
      flash[:notice] = '创建音乐成功'
    else
      flash[:alert] = "创建音乐失败"
    end

    redirect_to boombox_dj_tracks_url
  end

  def update
    if @track.update(track_params)
      if params[:boom_track][:track_tag_names].present?
        subject_relate_tag(params[:boom_track][:track_tag_names], @track)
      end
      if params[:boom_track][:artists].present?
        subject_relate_tag(params[:boom_track][:artists], @track, false)
      end
      flash[:notice] = '编辑音乐成功'
    else
      flash[:alert] = '编辑音乐失败'
    end

    redirect_to boombox_dj_tracks_url
  end

  def edit
    @tag_names = get_all_tag_names
    get_all_track_artists
  end

  def destroy
    if @track.destroy!
      flash[:notice] = '删除音乐成功'
    else
      flash[:alert] = @track.errors.full_messages
    end
    redirect_to boombox_dj_tracks_url
  end

  private

  def get_all_track_artists
    artist_names = []
    all_artists = BoomTrack.pluck(:artists)
    all_artists.map do |art|
      if art.present?
        artist_names << art.split(",")
      end
    end

    @artist_names = artist_names.flatten.uniq
  end

  def get_track
    @track = BoomTrack.find(params[:id])
  end

  def track_params
    params.require(:boom_track).permit(:cover, :name, :is_top, :file, :artists, :duration)
  end
end
