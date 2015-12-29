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
      @boom_topics = boom_topics.order(is_top: :desc, created_at: :desc).page(params[:topics_page]).per(params[:topics_per])
    end

    # 发布动态
    @boom_topic = current_collaborator.boom_topics.new 

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

  def create
    if params[:boom_topic].present?
      if @boom_topic = current_collaborator.boom_topics.create(boom_topic_params)
        if params[:attachment_ids].present?
          BoomTopicAttachment.where(id: params[:attachment_ids].split(',')).update_all(boom_topic_id: @boom_topic.id)
        end
        redirect_to boombox_dj_boom_topics_url, notice: '新建成功'
      else
        flash[:alert] = @boom_topic.errors.full_messages.to_sentence
        render action: 'index'
      end
    end
  end

  def create_attachment
    if params[:file].present?
      @file = BoomTopicAttachment.create(image: params[:file])
    end

    respond_to do |format|
      format.json { render json: @file.id }
    end
  end

  def destroy_attachment
    if !attachment_exists? || attachment_delete_success?
      respond_to do |format|
        format.json {
          render json: { message: '删除成功！', status: 200 }
        }
      end
    else
      respond_to do |format|
        format.json {
          render json: { message: '删除失败！', status: 403 }
        }
      end
    end
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

  private
  
  def boom_topic_params
    params.require(:boom_topic).permit(:content, :video_title, :video_url, attachments: [:image])
  end

  def attachment_exists?
    BoomTopicAttachment.where(id: params[:id]).any?
  end

  def attachment_delete_success?
    if params[:id].present? && BoomTopicAttachment.find(params[:id]).delete
      true
    else
      false
    end
  end
end
