class Operation::UsersController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    if params[:q]
      @users = User.search(params[:q]).page(params[:page])
    else
      @users = User.page(params[:page])
    end
  end
end
