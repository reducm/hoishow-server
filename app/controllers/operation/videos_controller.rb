# encoding: utf-8
class Operation::VideosController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_video, except: [:new, :create] 
  before_action :get_star, except: [:new, :create]

  def index
  end

  def show
  end

  def new
    @video = Video.new 
  end

  def create
    @video = Video.new(video_create_params) 
    if @video.save
      respond_to do |format|
        format.json {render nothing: true}
      end
    end
  end

  def edit
  end

  def update 
    if params[:video] 
      begin
        @video.update!(video_params)
        redirect_to edit_operation_star_url(@star), notice: '上传截图成功。'
      rescue => ex
        flash[:alert] = ex.message
        render action: 'edit'
      end
    end
  end

  def set_main 
    @videos = Video.where("star_token = ? OR star_id = ?", @star.token, @star.id)
    @videos.update_all(is_main: false)
    @video.update(is_main: true)
    redirect_to edit_operation_star_url(@star)
  end

  def destroy
    @video.destroy
    unless @star.videos.is_main.any?
      flash[:warning] = "明星没有主视频，请设置或上传" 
    end
    redirect_to edit_operation_star_url(@star)
  end

  private
  def video_create_params
    params[:video][:source] = params[:file]
    params.require(:video).permit(:star_id, :source, :snapshot, :star_token)
  end

  def video_params
    params.require(:video).permit(:star_id, :source, :snapshot)
  end

  def get_video
    @video = Video.find(params[:id])
  end

  def get_star
    if @video.star.present?
      @star = @video.star
    elsif Star.where(token: @video.star_token).any?
      @star = Star.where(token: @video.star_token).first
    else
      raise "视频数据有问题，请联系管理员检查：\n#{@video}"
    end
  end
end
