class Operation::VideosController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_video, :get_star

  def index
  end

  def show
  end

  def new
  end

  def create
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
    @videos = Video.all
    @videos.update_all(is_main: false)
    @video.update(is_main: true)
    redirect_to edit_operation_star_url(@star)
  end

  def destroy
    @star = @video.star
    @video.destroy
    redirect_to edit_operation_star_url(@star)
  end

  private
  def video_params
    params.require(:video).permit(:snapshot)
  end

  def get_video
    @video = Video.find(params[:id])
  end

  def get_star
    @star = @video.star
  end
end
