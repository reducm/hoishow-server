# encoding: utf-8
class Operation::TopicsController < Operation::ApplicationController
  include Operation::ApplicationHelper
  before_filter :check_login!
  before_action :get_topic, except: [:create, :index, :destroy_topic]
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @topics = Topic.page(params[:page]).order("created_at desc")
  end

  def create
    @topic = Topic.new(topic_params)
    Topic.transaction do
      @topic.content = Base64.encode64(params[:content])
      if params[:creator] == current_admin.default_name
        @topic.creator_type = 'Admin'
        @topic.creator_id = current_admin.id
      else
        @topic.creator_type = 'Star'
        @topic.creator_id = params[:creator]
      end
      @topic.save!
    end
    render json: {success: true}
  end

  def edit
    @comments = @topic.comments.order("created_at desc").page(params[:page]).per(10)
    @stars = @topic.get_stars
  end

  def update
    Topic.transaction do
      @topic.content = Base64.encode64(params[:content])
      @topic.save!
      flash[:notice] = '内容修改成功'
    end

    flash[:notice] = "互动修改成功"
    redirect_to edit_operation_topic_url(@topic)
  end

  def set_topic_top
    @topic.update(is_top: params[:is_top])
    @topics = Topic.where(subject_type: @topic.subject_type, subject_id: @topic.subject_id).order("created_at desc").page(params[:page]).per(10)

    @topics = @topics.where(city_id: params[:city_id]) if params[:city_id]
  end

  def add_comment
    @comment = @topic.comments.new()
    Comment.transaction do
      @comment.content = Base64.encode64(params[:content])

      if params[:creator] == current_admin.default_name
        @comment.creator_type = 'Admin'
        @comment.creator_id = current_admin.id
      else
        @comment.creator_type = 'Star'
        @comment.creator_id = params[:creator]
      end

      if params[:parent_id]
        @comment.parent_id = params[:parent_id]
        #回覆评论
        message = Message.create(send_type: "comment_reply", creator_type: @comment.creator_type, creator_id: @comment.creator_id, subject_type: "Topic", subject_id: @topic.id, title: "你有新的回覆", content: remove_emoji_from_content( params[:content]))
        comment = Comment.find(params[:parent_id])
        if comment.creator_type == "User"
          creator = comment.creator
          if @comment.creator_type != "User"
            title = @comment.creator.name + "回复了你的评论"
          else
            title = @comment.creator.nickname + "回复了你的评论"
          end
          message.user_message_relations.where(user: creator).first_or_create!
          message.send_message_for_reply_comment(creator.mobile, title, message.content)
        end
      end

      message = Message.create(send_type: "topic_reply", creator_type: @comment.creator_type, creator_id: @comment.creator_id, subject_type: "Topic", subject_id: @topic.id, title: "你有新的回覆", content: remove_emoji_from_content( params[:content] ))
        if @topic.creator_type == "User"
          message.user_message_relations.where(user: @topic.creator).first_or_create!
        end
      @comment.save!
    end
    render json: {success: true}
  end

  def destroy_comment
    @comment = Comment.where(id: params[:comment_id]).first
    if @comment
      @comment.destroy
      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  def destroy_topic
    if @topic.destroy
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def refresh_comments
    @comments = @topic.comments.order("created_at desc").page(params[:page]).per(10)
    @stars = get_stars(@topic)
    respond_to do |format|
      format.js {}
    end
  end

  private
  def topic_params
    params.require(:topic).permit(:content, :subject_id, :subject_type, :city_id)
  end

  def get_topic
    @topic = Topic.find(params[:id])
  end

end
