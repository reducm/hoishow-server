class Boombox::V1::FeedbacksController < Boombox::V1::ApplicationController
  before_filter :get_user

  def create
    return error_respond("反馈内容不能为空") if params[:content].blank?

    @feedback = BoomFeedback.new(feedback_params)
    @feedback.user = @user if @user
    if @feedback.save
      render json: {msg: 'ok'}
    else
      error_respond('反馈失败')
    end
  end

  private
  def feedback_params
    params.permit(:content, :contact)
  end
end
