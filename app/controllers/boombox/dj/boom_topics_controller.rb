class Boombox::Dj::BoomTopicsController < Boombox::Dj::ApplicationController
  before_filter :check_login!

  def index
    params[:topics_page] ||= 1
    params[:topics_per] ||= 10
    boom_topics = current_collaborator.boom_topics 
    # 按关键词过滤
    if params[:topics_q].present?
      # 由于content字段用base64加密
      # 调用es的search搜索（排序也用es处理）
      @boom_topics = boom_topics.search(params[:topics_q]).page(params[:topics_page]).per(params[:topics_per]).records
    else
      @boom_topics = boom_topics.order(created_at: :desc).page(params[:topics_page]).per(params[:topics_per])
    end

    respond_to do |format|
     format.html
     format.js
    end
  end

  def show
    params[:comments_page] ||= 1
    params[:likers_page] ||= 1
    params[:comments_per] ||= 10
    params[:likers_per] ||= 10
    @boom_topic = BoomTopic.find(params[:id])

    # comments
    boom_comments = @boom_topic.boom_comments
    if params[:comments_q].present?
      # 由于content字段用base64加密
      # 调用es的search搜索（排序也用es处理）
      @comments = boom_comments.search(params[:comments_q]).page(params[:comments_page]).per(params[:comments_per]).records
    else
      @comments = boom_comments.order(created_at: :desc).page(params[:comments_page]).per(params[:comments_per])
    end

    # likers，按关注先后排序
    likers = User.unscoped.joins(:boom_user_likes).where(boom_user_likes: { subject_id: @boom_topic.id, subject_type: 'BoomTopic' })
    @likers = likers.order("boom_user_likes.created_at").page(params[:likers_page]).per(params[:likers_per])
  end

  def destroy 
    @boom_topic = BoomTopic.find(params[:id])
    if @boom_topic.destroy
      redirect_to boombox_dj_boom_topics_url, notice: '删除成功'
    else
      flash[:alert] = @boom_topic.errors.full_messages.to_sentence
      render action: 'show'
    end
  end
end
