# encoding: utf-8
class Operation::UsersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_user, except: [:index]
  load_and_authorize_resource

  def index
    @users = User.all
  end

  def show
    @orders = @user.orders.page(params[:page])
    @topics = @user.topics.page(params[:page])
    @comments = @user.comments.page(params[:page])
  end

  def block_user
    @user.update(is_block: params[:is_block])

    redirect_to operation_users_url
  end

  def remove_avatar
    @user.remove_avatar!
    @user.avatar = nil
    @user.save

    redirect_to operation_user_url(@user)
  end

  private
  def get_user
    @user = User.find(params[:id])
  end
end
