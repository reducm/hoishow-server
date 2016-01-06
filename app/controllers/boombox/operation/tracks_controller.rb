# encoding: utf-8
class Boombox::Operation::TracksController < Boombox::Operation::ApplicationController
  include ConvertAudio::Logger
  before_filter :check_login!, except: [:convert_audio_notify]
  before_filter :get_track, except: [:search, :index, :new, :create, :convert_audio_notify]

  def index
    params[:tracks_page] ||= 1
    params[:tracks_per] ||= 10
    tracks = BoomTrack.valid

    if params[:tracks_start_time].present?
      tracks = tracks.where("created_at > '#{params[:tracks_start_time]}'")
    end

    if params[:tracks_end_time].present?
      tracks = tracks.where("created_at < '#{params[:tracks_end_time]}'")
    end

    if params[:tracks_is_top].present?
      tracks = tracks.where(is_top: params[:tracks_is_top])
    end

    if params[:tracks_q].present?
      tracks = tracks.where("name like ?", "%#{params[:tracks_q]}%")
    end

    @tracks = tracks.page(params[:tracks_page]).order("created_at desc").per(params[:tracks_per])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @tag_names = get_all_tag_names
    @track = BoomTrack.new
    get_all_track_artists
  end

  def create
    @track = BoomTrack.new(track_params)
    @track.creator_id = @current_admin.id
    @track.creator_type = BoomTrack::CREATOR_ADMIN

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

    redirect_to boombox_operation_tracks_url
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

    redirect_to boombox_operation_tracks_url
  end

  def edit
    @tag_names = get_all_tag_names
    get_all_track_artists
  end

  def destroy
    if @track.destroy
      flash[:notice] = "删除音乐成功"
    else
      flash[:alert] = "删除音乐失败"
    end

    redirect_to boombox_operation_tracks_url
  end

  def change_is_top
    if @track.is_top
      @track.update(is_top: false)
      flash[:notice] = "取消推荐成功"
    else
      @track.update(is_top: true)
      flash[:notice] = "更新推荐成功"
    end
    redirect_to boombox_operation_tracks_url
  end

  def convert_audio_notify
    upyun_logger.info '============'
    upyun_logger.info params

    render nothing: true
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
