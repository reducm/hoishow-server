# encoding: utf-8
class Api::V1::TicketsController < Api::V1::ApplicationController
  before_action :check_admin_validness!
  skip_before_filter :api_verify

  def get_ticket
    @ticket = Ticket.where(code: params[:code]).first    
  end

  def check_tickets
    if params[:codes].present?
      @tickets = Ticket.where(code: params[:codes], status: "success")
      if @tickets.any?
        check_ticket_status_and_update
      else
        return error_json "获取门票失败"
      end
    else
      return error_json "获取票码失败"
    end
  end

  private
  def check_ticket_status_and_update
    Ticket.transaction do
      @tickets.each do |ticket|
        unless ticket.update(status: "used", checked_at: Time.now, admin_id: @admin.id) 
          error_json "网络错误，请重试"
        end
      end
    end
    render json: {msg: "ok"}, status: 200
  end
end
