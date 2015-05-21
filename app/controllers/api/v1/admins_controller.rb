class Api::V1::AdminsController < Api::V1::ApplicationController
  skip_before_filter :api_verify

  def sign_in 
    admin = Admin.find_by_name(params[:name])
    if admin.present?
      if verify_block?(admin)
        return error_json "账户被锁定，请联系管理员"
      elsif admin.admin_type != "ticket_checker" 
        return error_json "账户无验票权限"
      elsif admin && admin.password_valid?(params[:password])
        admin.update(last_sign_in_at: DateTime.now)
        @admin = admin
      end
    else
      return error_json "账号或密码错误"
    end
  end

  def check_tickets
    @codes = params[:codes]
    @admin_id = params[:admin_id]
    if (Admin.find(@admin_id) rescue nil) 
      if @codes.any?
        @tickets = Ticket.where(code: @codes, status: "success")
        check_ticket_status_and_update
      end
    else
      error_json "获取验票员信息异常，请重新登陆"
    end
  end

  private

  def check_ticket_status_and_update
    if @tickets.any?
      @tickets.each do |ticket|
        unless ticket.update(status: "used", checked_at: Time.now, admin_id: @admin_id) 
          error_json "网络错误，请重试"
        end
      end
      render json: {msg: "ok"}, status: 200
    else
      return error_json "门票已使用或已过期"
    end
  end

end
