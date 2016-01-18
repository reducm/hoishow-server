class Boombox::Operation::BoomCommentsController < Boombox::Operation::ApplicationController
  load_and_authorize_resource

  def hide
    @boom_comment.update_attributes(is_hidden: true)
    flash[:notice] = "屏蔽成功"
    redirect_to boombox_operation_boom_topic_url(@boom_comment.boom_topic)
  end
end
