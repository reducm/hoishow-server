class Boombox::Dj::SessionsController < Boombox::Dj::ApplicationController
  before_filter :check_login!, only: [:destroy]

  def new
  end

  def create
    admin = BoomAdmin.find_by_name(params[:dj_session][:dj_username])
    if admin
      case
      when verify_block?(admin)
        flash[:alert] = "账户被锁定，请联系管理员"
        redirect_to boombox_dj_signin_url
      when !admin.dj?
        flash[:alert] = '账号没权限进入DJ后台，请联系管理员'
        redirect_to boombox_dj_signin_url
      when !admin.email_confirmed
        flash[:notice] = "我们重新给您发送了验证邮件，请登录您的邮箱按照提示操作"
        BoomAdminMailer.registration_confirmation(admin).deliver_now
        redirect_to boombox_dj_signup_send_email_url(boom_admin_id: admin.id)
      when Collaborator.where(boom_admin_id: admin.id).blank?
        flash[:alert] = '请先完善资料'
        redirect_to boombox_dj_signup_fill_personal_form_url(boom_admin_id: admin.id)
      when admin.password_valid?(params[:dj_session][:dj_password])
        admin.update(last_sign_in_at: DateTime.now)
        session[:dj_admin_id] = admin.id

        #url = session[:dj_request_page] ? session[:dj_request_page] : boombox_dj_root_url
        #redirect_to url
        redirect_to boombox_dj_root_url
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
    session[:dj_admin_id] = nil
    redirect_to boombox_dj_signin_url, :notice => "登出成功!"
  end
end
