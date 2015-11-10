# encoding: utf-8
class Boombox::Operation::BoomFeedbacksController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
    @boom_feedbacks = BoomFeedback.page(params[:page])
  end

  def search
    query_str = "created_at > '#{params[:start_time]}' and created_at < '#{params[:end_time]}'"

    if params[:q].present?
      query_str = query_str + " and content like '%#{params[:q]}%'"
    end

    if params[:select_options].present?
      case params[:select_options]
      when "0"
        @boom_feedbacks = BoomFeedback.where(query_str).page(params[:page]).order("created_at desc")
      when "1"
        @boom_feedbacks = BoomFeedback.where(status: false).where(query_str).page(params[:page]).order("created_at desc")
      when "2"
        @boom_feedbacks = BoomFeedback.where(status: true).where(query_str).page(params[:page]).order("created_at desc")
      end
    end
    render :index
  end

  def update_status
    @boom_feedback = BoomFeedback.find(params[:id])
    @boom_feedback.update(status: params[:status])
    redirect_to boombox_operation_boom_feedbacks_url
  end
end
