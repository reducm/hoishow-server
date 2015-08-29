class Operation::SiteSettingController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_data, except: [:index, :new, :create]
  before_action :is_block?, only: [:edit, :destroy]

  def index
    @data_list = CommonData.all
  end

  def new
    @data = CommonData.new
  end

  def create
    @data = CommonData.new(common_data_params)
    if @data.save
      flash[:notice] = '参数创建成功'
      redirect_to operation_site_setting_index_url
    else
      flash[:error] = '参数创建失败'
      render :new
    end
  end

  def edit
  end

  def update
    if @data.update(common_data_params)
      flash[:notice] = '参数修改成功'
      redirect_to operation_site_setting_index_url
    else
      flash[:error] = '参数修改失败'
      render :edit
    end
  end

  def destroy
    if @data.destroy
      flash[:notice] = '参数删除成功'
    else
      flash[:error] = '参数删除失败'
    end
    redirect_to operation_site_setting_index_url
  end

  def set_block
    @data.update(is_block: params[:is_block])

    redirect_to operation_site_setting_index_url
  end

  private
  def get_data
    @data = CommonData.find params[:id]
  end

  def common_data_params
    params.require(:common_data).permit(:common_key, :common_value, :remark)
  end

  def is_block?
    if @data.is_block
      flash[:notice] = '参数被锁定不能修改，请联系管理员'

      redirect_to operation_site_setting_index_url
    end
  end
end
