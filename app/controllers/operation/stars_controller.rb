class Operation::StarsController < Operation::ApplicationController
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
