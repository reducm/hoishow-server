# encoding: utf-8
class Boombox::Operation::BoomUsersController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
    params[:page] ||= 1
    params[:per] ||= 10
    boom_users = User.all

    if params[:q].present?
      boom_users = boom_users.where("users.nickname like '%#{params[:q]}%' or users.mobile like '%#{params[:q]}%'")
    end

    @users = boom_users.page(params[:users_page]).order("created_at desc").per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end

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
