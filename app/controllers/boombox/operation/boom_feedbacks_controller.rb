# encoding: utf-8
class Boombox::Operation::BoomFeedbacksController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
    params[:page] ||= 1
    params[:per] ||= 10
    boom_feedbacks = BoomFeedback.all

    if params[:q].present?
      boom_feedbacks = boom_feedbacks.search(params[:q]).records
    end

    if params[:start_time].present?
      boom_feedbacks = boom_feedbacks.where("created_at > '#{params[:start_time]}'")
    end

    if params[:end_time].present?
      boom_feedbacks = boom_feedbacks.where("created_at < '#{params[:end_time]}'")
    end

    if params[:status].present?
      boom_feedbacks = boom_feedbacks.where(status: params[:status])
    end

    @boom_feedbacks = boom_feedbacks.page(params[:page]).order("created_at desc").per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def update_status
    @boom_feedback = BoomFeedback.find(params[:id])
    @boom_feedback.update(status: params[:status])
    redirect_to boombox_operation_boom_feedbacks_url
  end
end
