# encoding: utf-8
class Operation::UsersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_user, except: [:index, :search]
  load_and_authorize_resource

  def index
    @users = User.page(params[:page]).order("created_at desc")
  end

  def search
    @users = User.where("nickname like ? or mobile like ?", "%#{params[:q]}%", "%#{params[:q]}%").page(params[:page]).order("created_at desc")
    render :index
  end

  def show
  end

  def block_user
    @user.update(is_block: params[:is_block])

    redirect_to operation_users_url
  end

  def remove_avatar
    @user.remove_avatar!
    @user.remove_avatar = true
    @user.save!

    redirect_to operation_user_url(@user)
  end

  private
  def get_user
    @user = User.find(params[:id])
  end
end
