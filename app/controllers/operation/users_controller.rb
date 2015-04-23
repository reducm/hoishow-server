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

  def show
    @user = User.find(params[:id])
    @orders = @user.orders.page(params[:page])
    @topics = @user.topics.page(params[:page])
    @comments = @user.comments.page(params[:page])
  end
end
