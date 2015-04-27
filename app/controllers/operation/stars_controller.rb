class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_star, except: [:index, :sort, :new, :create]
  before_action :get_star, except: [:index, :sort]
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
    if !@star.save
      render action: :new
    else
      redirect_to operation_stars_url, notice: "新增艺人成功。"
    end
  end

  def edit

  end

  def update

  end

  private

  def star_params
    params.require(:star).permit(:name, :avatar)
  end

  def get_star
    @star = Star.find(params[:id])
  end

end
