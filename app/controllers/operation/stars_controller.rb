class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_star, except: [:index]
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

  def edit

  end

  def update

  end

  private
  def get_star
    @star = Star.find(params[:id])
  end

end
