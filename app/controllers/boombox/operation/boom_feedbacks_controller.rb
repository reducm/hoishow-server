# encoding: utf-8
class Boombox::Operation::BoomFeedbacksController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
    @boom_feedbacks = BoomFeedback.page(params[:page])
  end

  def search
    @boom_feedbacks = BoomFeedback.page(params[:page])
    render :index
  end
end
