# encoding: utf-8
class Boombox::Dj::ApplicationController < ApplicationController
  layout "boombox_dj"

  before_filter :check_login!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to boombox_dj_root_url, :alert => exception.message
  end

  protected

  def check_login!
    unless current_admin
      session[:dj_request_page] = request.original_url
      flash[:warning] = "Please login"
      redirect_to boombox_dj_signin_url
    end
  end

  def current_admin
    @current_admin ||= BoomAdmin.where(id: session[:dj_admin_id], admin_type: BoomAdmin.admin_types[:dj]).first if session[:dj_admin_id]
  end

  # 登陆后得到该dj  
  def current_collaborator
    Collaborator.where(boom_admin_id: current_admin.id).first 
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_admin)
  end

  ## 新回复
  #def unread_comments_count
  #end

  helper_method :current_admin
  helper_method :current_collaborator
end