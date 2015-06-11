# encoding: utf-8
class Api::V1::AlipayController < Api::V1::ApplicationController
  skip_before_filter :api_verify
  include AlipayApi

  def notify
    alipay_params = params.except(*request.path_parameters.keys)
    if valid_success_pay?(alipay_params)
      render text: "success"
    else
      render text: "fail"
    end
  end

  def wireless_refund_notify
    alipay_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.wireless_refund_verify?(alipay_params)
      result_details = alipay_params[:result_details].split("#")
      result_details.each do |result|
        details = result.split("^")
        if ["SUCCESS", "TRADE_HAS_CLOSED"].include?(details.last)
          payment = Payment.where(trade_id: details.first).first
          order = payment.purchase
          if order.present? and !order.refund?
            payment.update(status: :refund, refund_amount: details[1].to_f, refund_at: Time.now)
            order.refund_tickets
            order.update(status: :refund)
          end
        #TODO 退款返回不成功的处理
        end
      end
      wp_print("alipay_params: #{alipay_params}")
      render text: "success"
    else
      render text: "fail"
    end
  end

  protected
  def valid_success_pay?(alipay_params)
    alipay_params = params.except(*request.path_parameters.keys)
    wp_print("alipay_params: #{alipay_params}")
    @order = Order.where(out_id: params[:out_trade_no]).first
    @payment = @order.alipay_pay
    #订单已经是支付成功或已经进入票务流程或失败或退款时，不需要再改变订单状态
    return true if @order.success? || @order.refund? || @order.outdate?
    if Alipay::Notify.app_verity?(alipay_params) && @order.amount.to_f == alipay_params[:total_fee].to_f
      if alipay_params["trade_status"] == "TRADE_SUCCESS"
        wp_print("into params_valid?")
        @order.update(status: :paid)
        @payment.update(
          trade_id: alipay_params["trade_no"],
          status: :success,
          pay_at: Time.now
        )
        if @order.paid?
          @order.set_tickets
          @order.update(status: :success)
        end
        wp_print("after order: #{@order}, #{@order.attributes}")
      end
      return true
    else
      return false
    end
  end

  def wp_print(str)
    Rails.logger.info(str)
  end
end
