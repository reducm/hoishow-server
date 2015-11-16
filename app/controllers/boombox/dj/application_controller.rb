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
      session[:request_page] = request.original_url
      flash[:warning] = "Please login"
      redirect_to boombox_dj_signin_url
    end
  end

  def current_admin
    @current_admin ||= BoomAdmin.where(id: session[:admin_id], admin_type: BoomAdmin.admin_types[:dj]).first if session[:admin_id]
  end

  def current_collaborator
    Collaborator.where(boom_admin_id: current_admin.id).first 
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_admin)
  end

  helper_method :current_admin
  helper_method :current_collaborator
end
