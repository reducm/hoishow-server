# encoding: utf-8
class Api::V1::AlipayController < Api::V1::ApplicationController
  skip_before_filter :api_verify
  include AlipayApi

  def notify
    alipay_params = params.except(*request.path_parameters.keys)
    wp_print("alipay_params: #{alipay_params}")
    @order = Order.where(out_id: alipay_params[:out_trade_no]).first
    #订单已经是支付成功或已经进入票务流程或失败或退款时，不需要再改变订单状态
    return render text: "success" if @order.success? || @order.refund? || @order.outdate?

    if Alipay::Notify.v2_app_verify?(alipay_params) && @order.amount.to_f == alipay_params[:total_fee].to_f
      if alipay_params["trade_status"] == "TRADE_SUCCESS"
        wp_print("into params_valid?")
        # 是否需要跑两步，先从 pending 到 paid, 再直接从 paid 到 success ？
        @order.pre_pay!({payment_type: 'alipay', trade_id: alipay_params["trade_no"]})

        # 更新 tickets 状态
        @order.success_pay!

        wp_print("after order: #{@order}, #{@order.attributes}")
      end
      render text: "success"
    else
      render text: "fail"
    end
  end

  def refund_notify
    alipay_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.verify?(alipay_params)
      wp_print("alipay_params: #{alipay_params}")
      result_details = alipay_params[:result_details].split("#")
      result_details.each do |result|
        details = result.split("^")
        if ["SUCCESS", "TRADE_HAS_CLOSED"].include?(details.last)
          payment = Payment.where(trade_id: details.first).first
          order = payment.purchase
          if order.present? and !order.refund?
            order.refunds!({refund_amount: details[1].to_f, payment: payment, handle_ticket_method: 'refund'})
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

  private
  def wp_print(str)
    Rails.logger.info(str)
  end
end
