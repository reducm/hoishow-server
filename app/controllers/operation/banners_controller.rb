# encoding: utf-8
class Operation::BannersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_banner, except: [:index, :new, :create]

  def index
    @banners = Banner.all
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

  def show
  end

  def edit
  end

  def update
    if @banner.update(banner_params)
      redirect_to action: :index
    else
      flash[:notice] = @banner.errors.full_messages
      render :edit
    end
  end

  def destroy
    @banner.destroy
    redirect_to action: :index
  end

  protected
  def get_banner
    @banner = Banner.find(params[:id])
  end

  def banner_params
    params.require(:banner).permit(:subject_type, :subject_id, :poster, :description)
  end
end
