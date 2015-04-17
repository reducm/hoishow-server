class Operation::StarsController < Operation::ApplicationController
  def index
    @stars = Star.order("position")
  end

  def show
    @star = Star.find(params[:id])
  end

  def sort
    params[:star].each_with_index do |id, index|
      Star.find(id).update(position: index+1)
    end
    render nothing: true
  end

  def edit

  end

  def update

  end
end
