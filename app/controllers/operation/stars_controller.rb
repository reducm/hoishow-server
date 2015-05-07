class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_star, only: [:show]
  before_action :get_videos, only: [:edit]
  load_and_authorize_resource

  def index
    @stars = Star.order(:position)
  end

  def sort
    if params[:star].present?
      params[:star].each_with_index do |id, index|
        Star.where(id: id).update_all(position: index+1)
      end
    end
    render nothing: true
  end

  def new
    @star = Star.new
  end

  def create
    @star = Star.new(star_params)
    if @star.save
      create_video  
      redirect_to operation_star_url(@star), notice: '艺人创建成功。'
    else
      render action: 'new'
    end
  end

  def edit
    respond_to do |format|
      if @star.save
        params[:videos]['source'].each do |source|
          @video = @star.videos.create!(:source => source, :star_id => @star.id)
        end
        format.html { redirect_to operation_star_url(@star), notice: 'Star was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def show
    @concerts = @star.concerts.page(params[:page])
    @topics = @star.topics.page(params[:page])
    @users = @star.followers.page(params[:page])
  end

  def get_topics
    @topics = @star.topics.page(params[:page])
    render partial: 'operation/topics/table', locals: {topics: @topics}
  end

  def update
    if params[:videos]
      if @star.update!(star_params)
        create_video 
        redirect_to operation_star_url(@star), notice: '艺人更新成功。'
      else
        render action: 'edit'
      end
    else
      if @star.update(star_params_without_videos)
        redirect_to operation_star_url(@star), notice: '艺人更新成功。'
      else
        render action: 'edit'
      end
    end
  end    

  private

  def star_params
    params.require(:star).permit(:name, :is_display, :avatar, :poster, videos_attributes: [:id, :star_id, :source])
  end

  def star_params_without_videos
    params.require(:star).permit(:name, :is_display, :avatar, :poster)
  end

  def create_video
    params[:videos]['source'].each do |source|
      begin
        @video = @star.videos.create!(:source => source, :star_id => @star.id)
      rescue => ex 
        redirect_to edit_operation_star_url(Star.find(ex.record.star_id)), alert: ex.message
        return
      end
    end    
  end

  def get_star
    @star = Star.find(params[:id])
  end

  def get_videos
    @star = Star.find(params[:id])
    @videos = @star.videos.order(is_main: :desc)
  end
end
