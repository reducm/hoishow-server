class Operation::SessionsController < Operation::ApplicationController
  def new
    render layout: false
  end

  def create
    admin = Admin.find_by_name(params[:session][:username])
    if admin && admin.passwd_valid?(params[:session][:password])
      admin.update(last_sign_in_at: DateTime.now)
      session[:admin_id] = admin.id

      redirect_to operation_root_url
    else
      flash[:error] = "Invalid username or password"
      redirect_to operation_signin_url
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to operation_root_url, :notice => "Logged out!"
  end
end
