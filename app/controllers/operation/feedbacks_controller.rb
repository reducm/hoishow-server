class Operation::FeedbacksController < Operation::ApplicationController
  include Operation::ApplicationHelper
  before_filter :check_login!
  load_and_authorize_resource only: [:index]

  def index
    @feedbacks = Feedback.page(params[:page])
  end

  def destroy
    @feedback = Feedback.find params[:id]
    if @feedback.destroy
      flash[:notice] = '反馈删除成功'
    else
      flash[:error] = '反馈删除失败'
    end

    redirect_to operation_feedbacks_url
  end
end
