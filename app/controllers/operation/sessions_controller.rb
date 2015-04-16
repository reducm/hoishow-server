class Operation::SessionsController < Operation::ApplicationController
  def new
    render layout: false
  end

  def create
    admin = Admin.find_by_name(params[:session][:username])
    if admin && admin.passwd_valid?(params[:session][:password])
      session[:admin_id] = admin.id
      redirect_to operation_root_url, :notice => "Logged in!"
    else
      flash.alert = "Invalid username or password"
      redirect_to operation_signin_url
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to operation_root_url, :notice => "Logged out!"
  end
end
