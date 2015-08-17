# encoding: utf-8
class Operation::ApplicationController < ApplicationController
  layout "operation"

  before_filter :check_login!
  protected
  def check_login!
    unless current_admin
      session[:request_page] = request.original_url
      flash[:notice] = "Please login"
      redirect_to operation_signin_url
    end
  end

  def current_admin
    @current_admin ||= Admin.find_by_id(session[:admin_id]) if session[:admin_id]
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_admin)
  end

  helper_method :current_admin
end
