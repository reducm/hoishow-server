class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_star, except: [:index, :sort, :new, :create]
  load_and_authorize_resource

  def index
    @stars = Star.order("position")
  end

  def show
    @concerts = @star.concerts.page(params[:page])
    @topics = @star.topics.page(params[:page])
    @users = @star.followers.page(params[:page])
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

  def edit

  end

  def update
    respond_to do |format|
      if params[:videos]
        if @star.update(star_params)
          params[:videos]['source'].each do |source|
            @video = @star.videos.create!(:source => source, :star_id => @star.id)
          end
          format.html { redirect_to operation_star_url(@star), notice: 'Star was successfully updated.' }
        else
          format.html { render action: 'update' }
        end
      else
        if @star.update(star_params_without_videos)
          format.html { redirect_to operation_star_url(@star), notice: 'Star was successfully updated.' }
        else
          format.html { render action: 'update' }
        end
      end
    end    
  end

  private

  def star_params
    params.require(:star).permit(:name, :avatar, videos_attributes: [:id, :star_id, :source])
  end

  def star_params_without_videos
    params.require(:star).permit(:name, :avatar)
  end

  def get_star
    @star = Star.find(params[:id])
  end
end
