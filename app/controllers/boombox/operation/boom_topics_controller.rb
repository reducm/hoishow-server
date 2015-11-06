class Boombox::Operation::BoomTopicsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
  end

  # 置顶 
  def set_top 
    @boom_topic.update_attributes(is_top: true)
    redirect_to boombox_operation_boom_topics_url, notice: '置顶成功'
  end
end
