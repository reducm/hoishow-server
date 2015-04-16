class Operation::AdminsController < Operation::ApplicationController
  before_filter :check_login!, only: [:index]
  load_and_authorize_resource

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
      redirect_to operation_admins_url
    else
      render "new"
    end
  end
end
