class Operation::AdminsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :find_admin, except: [:index, :new, :create]
  load_and_authorize_resource param_method: :admin_params

  def index
    params[:page] ||= 1
    @admins = Admin.page(params[:page])
  end

  def new
    @admin = Admin.new
  end

  def create
    #@admin = Admin.new(name: params[:username], admin_type: params[:type].to_i)
    @admin = Admin.new(admin_params)
    @admin.set_password(params[:encrypted_password])

    if @admin.save
      redirect_to operation_admins_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    @admin.set_password(params[:pw1])
    if @admin.save!
      redirect_to operation_admins_url
    end
  end

  def block_admin
    @admin.update(is_block: params[:block])
    @admin.save!

    redirect_to operation_admins_url
  end

  private
  def admin_params
    params.require(:admin).permit(:name, :admin_type, :encrypted_password)
  end
  def find_admin
    @admin = Admin.find params[:id]
  end

end
