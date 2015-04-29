class Operation::VideosController < Operation::ApplicationController
  before_action :get_video

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
  end

  def destroy
    @star = @video.star
    @video.destroy
    redirect_to edit_operation_star_url(@star)
  end

  private
  def get_video
    @video = Video.find(params[:id])
  end
end
