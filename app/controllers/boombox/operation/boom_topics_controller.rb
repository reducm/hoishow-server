class Boombox::Operation::BoomTopicsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    params[:per] ||= 10
    # 按关键词过滤
    if params[:q].present?
      @boom_topics = @boom_topics.where("content like :search", search: "%#{params[:q]}%")
    end
    # 分页，每页显示数量
    @boom_topics = @boom_topics.page(params[:page]).per(params[:per])
    # 将参数回传 
    @is_top = params[:is_top]
    @per = params[:per]
  end

  # 置顶 
  def set_top 
    collaborator = @boom_topic.collaborator
    @boom_topic.update_attributes(is_top: true)
    redirect_to boombox_operation_collaborator_url(collaborator), notice: '置顶成功'
  end

  def show
    # comments/users
    params[:page] ||= 1
    params[:per] ||= 10

    comments = @boom_topic.boom_comments 
    if params[:q]
      comments = comments.where("content like :search", search: "%#{params[:q]}%")
    end
    @comments = comments.page(params[:page]).per(params[:per])

    @users = @boom_topic.likers.page(params[:page]).per(params[:per])
  end

  def destroy 
    collaborator = @boom_topic.collaborator
    if @boom_topic.delete
      redirect_to boombox_operation_collaborator_url(collaborator), notice: '删除成功'
    else
      flash[:alert] = @boom_topic.errors.full_messages.to_sentence
      render action: 'show'
    end
  end
end
