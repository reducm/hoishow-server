class Boombox::Dj::PagesController < Boombox::Dj::ApplicationController
  skip_before_filter :check_login!
  
  def after_create_boom_admin 
    @boom_admin = BoomAdmin.find(params[:boom_admin_id]) 
  end

  def after_create_collaborator
    @collaborator = Collaborator.find(params[:collaborator_id])
  end

  def resend_email
    @boom_admin = BoomAdmin.find(params[:boom_admin_id])
    BoomAdminMailer.registration_confirmation(@boom_admin).deliver_now
    flash[:notice] = "发送成功！请登录您的邮箱按照提示操作"
    redirect_to boombox_dj_signup_send_email_url(boom_admin_id: @boom_admin.id)
  end
end
