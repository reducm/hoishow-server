class Api::V1::TopicsController < ApplicationController
  def index
    params[:page] ||= 1
    if params[:subject_type] && params[:subject_id]
      @topics = Topic.where("subject_type = ? AND subject_id = ?", params[:subject_type], params[:subject_id]).page(params[:page])
    else
      @topics = Topic.page(params[:page])
    end
  end

  def show
    @topic = Topic.find(params[:id]) 
  end
end
