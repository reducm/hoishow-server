# encoding: utf-8
class Operation::BannersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_banner, except: [:sort, :index, :new, :create]

  def index
    params[:page] ||= 1
    @banners = Banner.page(params[:page])
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = current_admin.banners.create(banner_params)
    if @banner.errors.any?
      flash[:alert] = @banner.errors.full_messages.to_sentence
      render :new
    else
      flash[:notice] = "创建成功" 
      redirect_to operation_banners_url
    end
  end

  def show
  end

  def sort
    if params[:banner].present?
      params[:banner].each_with_index do |id, index|
        Banner.where(id: id).update_all(position: index+1)
      end
    end
    render nothing: true
  end

  def edit
  end

  def update
    if @banner.update(banner_params)
      redirect_to action: :index
      flash[:notice] = "更新成功" 
    else
      flash[:alert] = @banner.errors.full_messages.to_sentence
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
