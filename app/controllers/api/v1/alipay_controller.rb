# coding: utf-8
class Api::V1::AlipayController < Api::V1::ApplicationController
  include AlipayApi

  def notify
    alipay_params = params.except(*request.path_parameters.keys)
    if valid_success_pay?(alipay_params)
      render text: "success"
    else
      render text: "fail"
    end
  end

  def test_alipay_notify
    alipay_params = params.except(*request.path_parameters.keys)
    if params_valid?(alipay_params)
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
        @order.update_attributes(status: Order::ORDER_STATUS_PAID, pay_at: Time.now)
        @payment.update_attributes({
          trade_id: alipay_params["trade_no"],
          status: Payment::STATUS_SUCCESS,
          pay_at: Time.now
        })
        if @order.paid?
          @order.set_tickets_code
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