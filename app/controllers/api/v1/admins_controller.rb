#encoding: UTF-8
class Api::V1::AdminsController < Api::V1::ApplicationController
  skip_before_filter :api_verify
  before_action :check_admin_validness!

  def sign_in 
    if @admin.password_valid?(params[:password])
      @admin.update(last_sign_in_at: DateTime.now)
    else
      return error_json "账户或密码错误"
    end
  end

  def check_tickets
    if params[:codes].present?
      @tickets = Ticket.where(code: params[:codes], status: "success")
      if @tickets.any?
        check_ticket_status_and_update
      else
        return error_json "门票已使用或已过期"
      end
    else
      return error_json "获取票码失败"
    end
  end

  private

  def check_ticket_status_and_update
    @tickets.each do |ticket|
      unless ticket.update(status: "used", checked_at: Time.now, admin_id: @admin_id) 
        error_json "网络错误，请重试"
      end
    end
    render json: {msg: "ok"}, status: 200
  end

end
