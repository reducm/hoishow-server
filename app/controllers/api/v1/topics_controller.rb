class Api::V1::TopicsController < ApplicationController
  def index
    params[:page] ||= 1
    #@topics = Topic.page(params[:page])
    @topics = Topic.where("subject_type = ? AND subject_id = ?", params[:subject_type], params[:subject_id]).page(params[:page])
  end

  def show
   @topic = Topic.find(params[:id]) 
  end
end
