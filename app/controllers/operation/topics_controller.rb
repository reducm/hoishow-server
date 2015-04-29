class Operation::TopicsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_topic, except: [:new, :create]
  load_and_authorize_resource

  def new
    @topic = Topic.new
    @concert = Concert.find_by_id(params[:concert_id])
    @stars = []
    if params[:star_id]
     @stars = Star.where(id: params[:star_id])
    elsif @concert
     @stars = @concert.stars
     @city_id = params[:city_id]
    end
  end

  def create
    @topic = Topic.new(topic_params)
    Topic.transaction do
      if params[:creator] == current_admin.name
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
    @stars = get_stars(@topic)
  end

  def update
    Topic.transaction do
      @topic.update(topic_params)
    end
    redirect_to edit_operation_topic_url(@topic)
  end

  def set_topic_top
    @topic.update(is_top: params[:is_top])
    if @topic.subject_type == Topic::SUBJECT_CONCERT
      @topics = Topic.where(subject_type: @topic.subject_type, subject_id: @topic.subject_id, city_id: params[:city_id]).page(params[:page]).per(10)
    elsif @topic.subject_type == Topic::SUBJECT_STAR
      @topics = Topic.where(subject_type: @topic.subject_type, subject_id: @topic.subject_id).page(params[:page]).per(10)
    end
  end

  def add_comment
    @comment = @topic.comments.new()
    Comment.transaction do
      @comment.content = params[:content]
      if params[:parent_id]
        @comment.parent_id = params[:parent_id]
      end

      if params[:creator] == current_admin.name
        @comment.creator_type = 'Admin'
        @comment.creator_id = current_admin.id
      else
        @comment.creator_type = 'Star'
        @comment.creator_id = params[:creator]
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

  def get_stars(topic)
    case topic.subject_type
    when Topic::SUBJECT_CONCERT
      topic.subject.stars
    when Topic::SUBJECT_STAR
      Star.where(id: topic.subject_id)
    end
  end
end