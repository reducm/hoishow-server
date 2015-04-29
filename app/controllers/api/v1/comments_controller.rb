class Api::V1::CommentsController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    if params[:topic_id].present?
      @comments = Comment.where(topic_id: params[:topic_id]).page(params[:page])
    else
      @comments = Comment.page(params[:page])
    end
  end  
end
