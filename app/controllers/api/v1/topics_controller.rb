class Api::V1::TopicsController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    if params[:subject_type].present? && params[:subject_id].present? 
      @topics = Topic.where("subject_type = ? AND subject_id = ?", params[:subject_type], params[:subject_id]).page(params[:page])
    else
      @topics = Topic.page(params[:page])
    end
  end

  def show
    @topic = Topic.find(params[:id]) 
  end
end
