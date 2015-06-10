# encoding: utf-8
class Operation::CommentsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @comments = Comment.page(params[:page]).order("created_at desc")
  end

end

