# encoding: utf-8
class Boombox::Operation::BoomUsersController < Boombox::Operation::ApplicationController
  before_filter :get_boom_user, except: [:index]

  def index
    params[:users_page] ||= 1
    params[:users_per] ||= 10
    boom_users = User.all

    if params[:users_q].present?
      boom_users = boom_users.where("users.nickname like \"%#{params[:users_q]}%\" or users.mobile like \"%#{params[:users_q]}%\"")
    end

    @users = boom_users.page(params[:users_page]).order("users.created_at desc").per(params[:users_per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def show
    params[:user_comments_page] ||= 1
    user_comments = @user.boom_comments

    if params[:q].present?
      user_comments = user_comments.search(params[:q]).records
    end

    @user_comments = user_comments.page(params[:user_comments_page]).order("created_at desc")
    @like_topics = @user.boom_like_topics.page(params[:like_topics_page]).order("created_at desc")

    respond_to do |format|
      format.html
      format.js
    end

  end

  def block_comment
    if params[:comment_id].present?
      comment = BoomComment.find(params[:comment_id])
      if comment
        comment.update(is_hidden: true)
        flash[:notice] = "屏蔽成功"
      else
        flash[:notice] = "屏蔽失败"
      end
    end
    redirect_to boombox_operation_boom_user_url(@user)
  end

  def block_user
    @user.update(is_block: params[:is_block])

    redirect_to boombox_operation_boom_users_url
  end

  def remove_avatar
    @user.remove_avatar!
    @user.remove_avatar = true
    if @user.save
      flash[:notice] = "屏蔽头像成功"
    end

    redirect_to boombox_operation_boom_users_url
  end

  private
  def get_boom_user
    @user = User.find(params[:id])
  end
end
