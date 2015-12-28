class Boombox::Dj::BoomAdminsController < Boombox::Dj::ApplicationController
  skip_before_filter :check_login!

  def new
    @boom_admin = BoomAdmin.new
  end

  def create
    password = params[:boom_admin][:password]

    unless password.present?
      flash[:alert] = "请输入密码"
      render 'new'
      return
    end

    @boom_admin = BoomAdmin.new(boom_admin_params)
    @boom_admin.admin_type = BoomAdmin.admin_types[:dj] 
    @boom_admin.set_password(password)

    if @boom_admin.save
      BoomAdminMailer.registration_confirmation(@boom_admin).deliver_now
      flash[:notice] = "注册成功！请登录您的邮箱按照提示操作"
      redirect_to boombox_dj_signup_send_email_url(boom_admin_id: @boom_admin.id) 
    else
      flash[:alert] = @boom_admin.errors.full_messages.to_sentence
      render 'new'
    end
  end 

  def confirm_email
    dj = BoomAdmin.where(id: params[:id]).first

    if dj.present?
      if dj.email_confirmed?
        if Collaborator.where(boom_admin_id: dj.id).any?
          flash[:notice] = "欢迎使用播霸！请前往登录"
          redirect_to boombox_dj_root_url
        else
          flash[:notice] = "欢迎使用播霸！请完善您的个人资料"
          redirect_to boombox_dj_signup_fill_personal_form_url(boom_admin_id: dj.id)
        end
      else
        dj.email_activate
        flash[:notice] = "欢迎使用播霸！请完善您的个人资料"
        redirect_to boombox_dj_signup_fill_personal_form_url(boom_admin_id: dj.id)
      end
    else
      flash[:alert] = "用户不存在，请先注册"
      redirect_to boombox_dj_signup_url
    end
  end

  def send_reset_password_email
    if params[:boom_admins].present?
      if @boom_admin = BoomAdmin.dj.where(email: params[:boom_admins][:email]).first
        @boom_admin.set_confirmation_token
        BoomAdminMailer.forget_password(@boom_admin).deliver_now
        flash[:notice] = "发送成功！请登录您的邮箱按照提示操作"
        redirect_to boombox_dj_after_send_reset_password_email_url(boom_admin_id: @boom_admin.id)
      else
        flash[:alert] = "邮箱未注册"
        redirect_to boombox_dj_signin_url
      end
    # 重新发送
    elsif params[:boom_admin_id].present?
      if @boom_admin = BoomAdmin.dj.where(id: params[:boom_admin_id]).first
        @boom_admin.set_confirmation_token
        BoomAdminMailer.forget_password(@boom_admin).deliver_now
        flash[:notice] = "发送成功！请登录您的邮箱按照提示操作"
        redirect_to boombox_dj_after_send_reset_password_email_url(boom_admin_id: @boom_admin.id)
      else
        flash[:alert] = "未授权操作"
        redirect_to boombox_dj_signin_url
      end
    end
  end

  def new_password
    unless params[:token].present? && BoomAdmin.dj.where(confirm_token: params[:token]).any?
      flash[:alert] = "未授权操作"
      redirect_to boombox_dj_signin_url
    end
  end

  def reset_password
    @boom_admin = BoomAdmin.find(params[:id])
    if params[:password].present? && params[:password_confirmation].present? && params[:password] == params[:password_confirmation]
      if @boom_admin.reset_password!(params[:password])
        flash[:notice] = "密码重置成功，请使用新密码登录"
        redirect_to boombox_dj_signin_url
      else
        flash[:alert] = @boom_admin.errors.full_messages.to_sentence
        redirect_to new_password_boombox_dj_boom_admin_url(@boom_admin, token: @boom_admin.confirm_token)
      end
    else
      flash[:alert] = "密码为空或密码不一致，请重新输入"
      redirect_to new_password_boombox_dj_boom_admin_url(@boom_admin, token: @boom_admin.confirm_token)
    end
  end

  private
  def boom_admin_params
    params.require(:boom_admin).permit(:name, :email)
  end
end
