class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @stars = Star.order("position")
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
