# encoding: utf-8
class Operation::StartupController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_startup, only: [:update, :set_startup_status, :destroy]
  load_and_authorize_resource

  def index
    @startups = Startup.all
  end

  def create
    @startup = Startup.new(startup_params)
    @startup.save

    render json: {success: true}
  end

  def update
    if @startup.update(startup_params)
      flash[:notice] = '设置图片有效期成功'
      redirect_to operation_startup_index_url
    end
  end

  def set_startup_status
    Startup.update_all(is_display: 0)

    if params[:is_display]
      @startup.update(is_display: 1)
      flash[:notice] = '设置启动图片成功'
    else
      flash[:notice] = '取消设置成功'
    end

    redirect_to operation_startup_index_url
  end

  def destroy
    if @startup.destroy
      flash[:notice] = '删除成功'
      redirect_to operation_startup_index_url
    end
  end

  private
  def startup_params
    params.require(:startup).permit(:pic, :valid_time, :is_display)
  end

  def get_startup
    @startup = Startup.find(params[:id])
  end
end
