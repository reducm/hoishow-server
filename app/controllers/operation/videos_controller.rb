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
    @star = Star.find(params[:star_id])
  end

  def create
    @star = Star.find(params[:video][:star_id])
    @video = Video.new(video_create_params) 
    unless @star.videos.any?
      @video.update(is_main: true)
    end
    if @video.save
      respond_to do |format|
        flash.now[:notice] = '视频上传成功。'
        format.html {redirect_to edit_operation_star_url(@video.star)} 
        format.json {render nothing: true}
      end
    else
      flash.now[:alert] = @video.errors.full_messages.to_sentence
      @video.delete
      render action: 'new'
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
    @videos = @star.videos 
    @videos.update_all(is_main: false)
    @video.update(is_main: true)
    redirect_to edit_operation_star_url(@star)
  end

  def destroy
    @star = @video.star
    @video.destroy
    unless @star.videos.is_main.any?
      flash[:warning] = "明星没有主视频，请设置或上传" 
    end
    redirect_to edit_operation_star_url(@star)
  end

  private
  def video_create_params
    params[:video][:source] = params[:file]
    params.require(:video).permit(:star_id, :source, :snapshot)
  end

  def video_params
    params.require(:video).permit(:star_id, :source, :snapshot)
  end

  def get_video
    @video = Video.find(params[:id])
  end

  def get_star
    @star = @video.star
  end
end
