# encoding: utf-8
class Operation::SessionsController < Operation::ApplicationController
  before_filter :check_login!, only: [:destroy]

  def new
  end

  def create
    admin = Admin.find_by_name(params[:session][:username])
    if admin
      if verify_block?(admin)
        flash[:alert] = "账户被锁定，请联系管理员"
        redirect_to operation_signin_url
      elsif admin.password_valid?(params[:session][:password])
        admin.update(last_sign_in_at: DateTime.now)
        session[:admin_id] = admin.id

        redirect_to operation_root_url
      end
    else
      flash[:alert] = "账号或密码错误"
      redirect_to operation_signin_url
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to operation_signin_url, :notice => "Logged out!"
  end
end
