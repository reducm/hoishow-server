class Api::V1::FeedbacksController < Api::V1::ApplicationController
  def create
    return error_json("反馈内容/联系方式不能为空") if params[:content].blank? || params[:mobile].blank?

    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      render json: {msg: 'ok'}
    else
      render error_json('反馈失败')
    end
  end

  private
  def feedback_params
    params.permit(:content, :mobile)
  end
end
