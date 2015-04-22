class Operation::ConcertsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    if params[:q].present?
      @stars = Star.search(params[:q])
      @concerts = Kaminari.paginate_array( @stars.map{|star| star.concerts}.flatten ).page(params[:page])
    elsif params[:p].present?
      @concerts = Concert.where(status: params[:p]).page(params[:page])
    else
      @concerts = Concert.page(params[:page])
    end
  end

  def show

  end

  def edit
    @concert = Concert.find(params[:id])
    @concert_shows = @concert.shows.page(params[:page])
  end

  def update
    @concert = Concert.find(params[:id])
    if @concert.update!(validate_attributes)
      redirect_to operation_concerts_url
    else
      flash[:notice] = @concert.errors.full_messages
      render :edit
    end
  end

  private
    def validate_attributes
      params.require(:concert).permit(:name, :status, :start_date, :end_date, :description)
    end
end
