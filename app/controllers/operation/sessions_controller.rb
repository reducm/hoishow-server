# encoding: utf-8
class Operation::SessionsController < Operation::ApplicationController
  before_filter :check_login!, only: [:destroy]

  def new
  end

  def create
    admin = Admin.find_by_name(params[:session][:username])
    if admin
      case
      when verify_block?(admin)
        flash[:alert] = "账户被锁定，请联系管理员"
        redirect_to operation_signin_url
      when admin.ticket_checker?
        flash[:alert] = '验票账号没权限进入后台，请联系管理员'
        redirect_to operation_signin_url
      when admin.password_valid?(params[:session][:password])
        admin.update(last_sign_in_at: DateTime.now)
        session[:admin_id] = admin.id

        url = session[:request_page] ? session[:request_page] : operation_root_url
        redirect_to url
      else
        flash[:alert] = '密码错误, 请重新输入'
        redirect_to operation_signin_url
      end
    else
      flash[:alert] = "账号不存在，请重新输入"
      redirect_to operation_signin_url
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to operation_signin_url, :notice => "登出成功!"
  end
end
