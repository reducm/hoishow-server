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
    dj = BoomAdmin.find(params[:id])
    boom_admin = BoomAdmin.where(confirm_token: dj.confirm_token).first
    if boom_admin
      boom_admin.email_activate
      flash[:notice] = "欢迎使用播霸！请完善您的个人资料"
      redirect_to boombox_dj_signup_fill_personal_form_url(boom_admin_id: boom_admin.id) 
    else
      flash[:alert] = "Sorry. boom_admin does not exist"
      redirect_to boombox_dj_root_url
    end
  end

  private
  def boom_admin_params
    params.require(:boom_admin).permit(:name, :email)
  end
end
