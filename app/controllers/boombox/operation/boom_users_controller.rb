# encoding: utf-8
class Boombox::Operation::BoomUsersController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
    @users = User.page(params[:users_page]).order("created_at desc")
  end

  def search
    @users = User.where("nickname like ? or mobile like ?", "%#{params[:q]}%", "%#{params[:q]}%").page(params[:page]).order("created_at desc")
    render :index
  end

  def show
    @user = User.find(params[:id])
  end

  def block_user
    @user = User.find(params[:id])
    @user.update(is_block: params[:is_block])

    redirect_to boombox_operation_boom_users_url
  end
end
