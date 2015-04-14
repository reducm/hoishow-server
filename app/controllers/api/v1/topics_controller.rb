class Api::V1::TopicsController < ApplicationController
  def index
    params[:page] ||= 1
    if params[:subject_type].nil? || params[:subject_id].nil?
      @topics = Topic.page(params[:page])
    else
      @topics = Topic.where("subject_type = ? AND subject_id = ?", params[:subject_type], params[:subject_id]).page(params[:page])
    end
  end

  def show
   @topic = Topic.find(params[:id]) 
  end
end
