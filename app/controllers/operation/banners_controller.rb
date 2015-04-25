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
  end

  def edit
    
  end

  def update
    
  end

  def destroy
    
  end

  protected
  def banner_params
    params.require(:banner).permit(:subject_type, :subject_id, :poster, :description, :slogan)
  end
end
