# encoding: utf-8
class Boombox::Operation::TracksController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_track, except: [:index, :new, :create]

  def index
    @tracks = BoomTrack.page(params[:page]).order("created_at desc")
  end

  def new
    @track = BoomTrack.new
  end

  def create
    @track = BoomTrack.new(track_params)
    @track.creator_id = @current_admin.id
    @track.creator_type = BoomTrack::CREATOR_ADMIN
    if @track.save!
      redirect_to boombox_operation_tracks_url
    end
  end

  def update
  end

  def edit

  end

  def destroy

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


  private
  def get_track
    @track = BoomTrack.find(params[:id])
  end

  def track_params
    params.require(:boom_track).permit(:cover, :name, :is_top, :file, :artists, :duration)
  end
end
