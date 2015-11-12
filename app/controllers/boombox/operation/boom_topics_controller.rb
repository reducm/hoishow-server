class Boombox::Operation::BoomTopicsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
  end

  # 置顶 
  def set_top 
    collaborator = @boom_topic.collaborator
    @boom_topic.update_attributes(is_top: true)
    redirect_to boombox_operation_collaborator_url(collaborator), notice: '置顶成功'
  end

  def show
    params[:comments_page] ||= 1
    params[:likers_page] ||= 1
    params[:comments_per] ||= 10
    params[:likers_per] ||= 10
    # comments
    boom_comments = @boom_topic.boom_comments
    if params[:comments_q].present?
      @comments = boom_comments.search(params[:comments_q]).page(params[:comments_page]).per(params[:comments_per]).records
    else
      @comments = boom_comments.order(created_at: :desc).page(params[:comments_page]).per(params[:comments_per])
    end

    # likers，按关注先后排序
    likers = User.unscoped.joins(:boom_user_likes).where(boom_user_likes: { subject_id: @boom_topic.id, subject_type: 'BoomTopic' })
    @likers = likers.order("boom_user_likes.created_at").page(params[:likers_page]).per(params[:likers_per])
  end

  def destroy 
    collaborator = @boom_topic.collaborator
    if @boom_topic.destroy
      redirect_to boombox_operation_collaborator_url(collaborator), notice: '删除成功'
    else
      flash[:alert] = @boom_topic.errors.full_messages.to_sentence
      render action: 'show'
    end
  end
end
