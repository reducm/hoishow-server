class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    if params[:query].present?
      @stars = Star.search(params[:query]).order("position")
    else
      @stars = Star.order("position")
    end
  end

  def show
    @star = Star.find(params[:id])
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
end
