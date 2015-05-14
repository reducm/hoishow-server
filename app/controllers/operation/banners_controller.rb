class Operation::BannersController < Operation::ApplicationController
  def index
    @banners = Banner.all
  end

  def show
    @banner = Banner.find(params[:id])   
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = current_admin.banners.create(banner_params)
    if @banner.errors.any?
      flash[:notice] = @banner.errors.full_messages
      render :new
    else
      redirect_to action: :index
    end
  end

  def edit
    @banner = Banner.find(params[:id])   
  end

  def update
    @banner = Banner.find(params[:id])   
    if @banner.update_attributes(params.require(:banner).permit(:poster, :description))
      redirect_to action: :index
    else
      flash[:notice] = @banner.errors.full_messages
      render :edit
    end
  end

  def destroy
    @banner = Banner.find(params[:id])   
    @banner.destroy
    redirect_to action: :index
  end

  protected
  def banner_params
    params.require(:banner).permit(:subject_type, :subject_id, :poster, :description)
  end
end
