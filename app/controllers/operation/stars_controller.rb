class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @stars = Star.page(params[:page])
  end

  def show
    @star = Star.find(params[:id])
  end

  def edit

  end

  def update

  end


end
