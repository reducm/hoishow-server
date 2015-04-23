class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_topic, except: [:index]
  load_and_authorize_resource

  def index
    @stars = Star.order("position")
  end

  def show
    @star = Star.find(params[:id])
    @topics = Topic.where(subject_type: "Star", subject_id: @star.id).page(params[:page])
  end

  def sort
    if params[:star].present?
      params[:star].each_with_index do |id, index|
        Star.where(id: id).update_all(position: index+1) 
      end
    end
    render nothing: true
  end

  def top_topic 
    @topic.update(is_top: true)
    @topic.save
    redirect_to operation_star_url(@star)
  end

  def no_top_topic 
    @topic.update(is_top: false)
    @topic.save
    redirect_to operation_star_url(@star)
  end

  def topic_comments 
    @comments = @topic.comments
    render 'ok'
  end

  def edit

  end

  def update

  end

  private
  def get_topic
    @topic = Topic.find(params[:id])
  end

end
