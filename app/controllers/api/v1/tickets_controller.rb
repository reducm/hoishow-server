# encoding: utf-8
class Api::V1::TicketsController < Api::V1::ApplicationController
  before_action :check_admin_validness!
  skip_before_filter :api_verify

  def get_ticket
    @ticket = Ticket.where(code: params[:code]).first
    return error_json '获取门票失败' if @ticket.nil?
  end

  def check_tickets
    if params[:codes].present?
      @tickets = Ticket.where(code: params[:codes].split(','), status: Ticket::statuses["success"])
      if @tickets.any?
        check_ticket_status_and_update
        # 由于没有sidkiq的测试，所以测试环境不跑
        # fix ./spec/controllers/api/v1/tickets_controller_spec.rb:34
        #   Error connecting to Redis on 127.0.0.1:6379 (Errno::ECONNREFUSED)
        unless Rails.env.test? 
          NotifyTicketCheckedWorker.perform_async(@tickets.first.order.open_trade_no)
        end

        render json: {msg: "ok"}, status: 200
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
        unless ticket.update(status: Ticket::statuses["used"], checked_at: Time.now, admin_id: @admin.id)
          error_json "网络错误，请重试"
        end
      end
    end
  end
end
