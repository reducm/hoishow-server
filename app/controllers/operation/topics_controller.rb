class Operation::TopicsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new
  end

  def show
    @topic = Topic.find(params[:id])
  end
end