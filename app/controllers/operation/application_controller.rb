class Operation::ApplicationController < ApplicationController
  layout "operation"

  protected
  def check_login!
    unless current_admin
      flash[:notice] = "Please login"
      redirect_to login_path
    end
  end

  def current_admin
    @current_admin ||= Admin.find_by_id(session[:admin_id]) if session[:admin_id]
  end

  helper_method :current_user
end
