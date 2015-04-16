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
    attributes = params.require(:concert).permit(:name, :status, :start_date, :end_date, :description)
    status_to_en(attributes)
    if @concert.update!(attributes)
      redirect_to operation_concerts_url
    else
      flash[:notice] = @concert.errors.full_messages
      render :edit
    end
  end

  def status_to_en(attributes)
    case attributes["status"]
    when "投票中"
      attributes["status"] = "voting"
    when "投票完结"
      attributes["status"] = "finished"
    end
  end


end
