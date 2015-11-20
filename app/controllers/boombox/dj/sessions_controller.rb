class Boombox::Dj::SessionsController < Boombox::Dj::ApplicationController
  before_filter :check_login!, only: [:destroy]

  def new
  end

  def create
    admin = BoomAdmin.find_by_name(params[:session][:username])
    if admin
      case
      when verify_block?(admin)
        flash[:alert] = "账户被锁定，请联系管理员"
        redirect_to boombox_dj_signin_url
      when !admin.dj?
        flash[:alert] = '账号没权限进入DJ后台，请联系管理员'
        redirect_to boombox_dj_signin_url
      when !admin.email_confirmed
        flash[:alert] = '账号没通过邮箱验证，请检查你的邮箱'
        redirect_to boombox_dj_signin_url
      when admin.password_valid?(params[:session][:password])
        admin.update(last_sign_in_at: DateTime.now)
        session[:admin_id] = admin.id

        url = session[:request_page] ? session[:request_page] : boombox_dj_root_url
        redirect_to url
      else
        flash[:alert] = '密码错误, 请重新输入'
        redirect_to boombox_dj_signin_url
      end
    else
      flash[:alert] = "账号不存在，请重新输入"
      redirect_to boombox_dj_signin_url
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to boombox_dj_signin_url, :notice => "登出成功!"
  end
end
