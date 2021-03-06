# encoding: utf-8
class Operation::AdminsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :find_admin, except: [:index, :new, :create]

  def index
    params[:page] ||= 1
    @admins = Admin.page(params[:page])
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(name: params[:username], admin_type: params[:type].to_i)
    @admin.set_password(params[:password])

    if @admin.save
      flash[:notice] = '管理员创建成功'
      redirect_to operation_admins_url
    else
      flash[:alert] = @admin.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if params[:pw1].present? && params[:pw1] == params[:pw2]
      @admin.set_password(params[:pw1])
    end
    @admin.admin_type = params[:type].to_i
    if @admin.save
      flash[:notice] = '修改成功'
      redirect_to operation_admins_url
    else
      flash[:alert] = @admin.errors.full_messages
      render :update
    end
  end

  def block_admin
    @admin.update(is_block: params[:block])
    @admin.save!

    redirect_to operation_admins_url
  end

  private
  def find_admin
    @admin = Admin.find params[:id]
  end
end
