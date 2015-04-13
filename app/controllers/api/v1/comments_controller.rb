class Api::V1::CommentsController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    @comments = Comment.page(params[:page])
  end  
end
