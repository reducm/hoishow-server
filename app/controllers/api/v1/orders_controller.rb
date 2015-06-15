# encoding: utf-8
class Api::V1::OrdersController < Api::V1::ApplicationController
  before_action :check_login!, except: [:show_for_qr_scan]
  before_action :check_admin_validness!, only: [:show_for_qr_scan]
  skip_before_filter :api_verify, only: [:show_for_qr_scan]

  def index
    @orders = @user.page_orders(params[:page])
  end

  def show
    @order = @user.orders.where(out_id: params[:id]).first
  end

  def orders_for_soon
    @orders = @user.orders.joins(:show).where("shows.show_time > ? and shows.show_time < ?", Time.now, Time.now.tomorrow.end_of_day).order('shows.show_time desc')
  end

  def show_for_qr_scan
    @order = Order.where(out_id: params[:id]).first
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
    @payment.update_attributes(amount: @order.amount, paid_origin: @auth.app_platform)
    @payment_type = params[:payment_type]

    case @payment_type  #传入一个支付类型
    when 'alipay'
      if @auth.app_platform == "android"
        options = {
          partner:         AlipaySetting["pid"],
          seller_id:       AlipaySetting["email"],
          out_trade_no:    @order.out_id,
          subject:         @order.payment_body,
          total_fee:       @order.amount.to_s,
          notify_url:      api_v1_alipay_notify_url,
          service:         "mobile.securitypay.pay",
          payment_type:    "1",
          _input_charset:  "utf-8",
          it_b_pay:        "10m"
        }
      end
      sign_string = Alipay::Utils.app_hash_to_string(options)
      options.merge!(sign: CGI.escape(Alipay::Sign.rsa_sign(sign_string, Alipay::Sign.pri_app_key_file)), sign_type: "RSA")
      @query_string = Alipay::Utils.app_hash_to_string(options)
    when 'wxpay'
      options = {
        body:             @order.payment_body,
        out_trade_no:     @order.out_id,
        total_fee:        @order.amount.to_s,
        notify_url:       api_v1_wxpay_notify_url,
        spbill_create_ip: request.remote_ip,
        time_start:       @order.created_at.strftime('%Y%m%d%H%M%S'),
        time_expire:      @order.valid_time.strftime('%Y%m%d%H%M%S'),
        user_id:          @order.user_id.to_s
      }

      @result_data = Wxpay::Service.prepay(options)

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
