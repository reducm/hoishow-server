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

        # Bike演出验票回调
        if params[:notify_url].present?
          url = "#{params[:notify_url]}?open_trade_no=#{@tickets.first.order.open_trade_no}"
          RestClient.get(url)
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
