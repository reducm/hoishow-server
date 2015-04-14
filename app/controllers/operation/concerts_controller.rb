class Operation::ConcertsController < Operation::ApplicationController
  def index
    @concerts = Concert.page(params[:page])
  end

  def show
    
  end

  def edit
    @concert = Concert.find(params[:id])
  end

  def update
    @concert = Concert.find(params[:id])
    if @concert.update_attributes(params[:concert].symbolize_keys)
      redirect_to :index
    else
      flash[:notice] = @concert.errors.full_messages
      render :edit
    end
  end
end
