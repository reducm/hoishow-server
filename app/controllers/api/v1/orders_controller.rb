class Api::V1::OrdersController < Api::V1::ApplicationController
  before_action :check_login!
  def index
    params[:page] ||= 1
    @orders = @user.orders.page(params[:page])
  end

  def show
    @order = @user.orders.where(out_id: params[:id]).first
  end

  def pay
    @order = Order.where(out_id: params[:id]).first
    if @order.status_outdate?
      error_json("订单已经过期...")
      return false
    end

    payment_options = {
      purchase_type: @order.class.name,
      purchase_id:   @order.id,
      payment_type:  params[:payment_type]
    }
    @payment = Payment.where(payment_options).first_or_initialize
    @payment.update_attributes(amount: @order.total_fee, paid_origin: @auth.app_platform)
    @payment_type = params[:payment_type]

    case @payment_type  #传入一个支付类型
    when 'alipay'
      #TODO @sign = Alipay::Sign.rsa_sign(params[:sign_string], Alipay::Sign.pri_app_key_file)
    when 'wepay'
      @payment.update_attributes(trade_id: @payment.generate_batch_no)
      options = {
        attach:           @order.out_id,
        body:             @order.payment_body,
        out_trade_no:     @payment.trade_id,
        total_fee:        @order.amount.to_s,
        notify_url:       api_v1_mobile_wepay_notify_url,
        spbill_create_ip: request.remote_ip,
        time_start:       @order.created_at.strftime('%Y%m%d%H%M%S'),
        time_expire:      @order.valid_time.strftime('%Y%m%d%H%M%S'),
        user_id:          @order.user_id.to_s
      }

      @result_data = Wepay::Service.prepay(options)

      if @result_data["result"] == "0"
        @sign = @result_data["data"]
      else
        return error_json("请求微信支付失败")
      end
    end

    respond_to do |f|
      f.json
    end
  end
end
