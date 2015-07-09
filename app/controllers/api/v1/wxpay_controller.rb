# encoding: utf-8
class Api::V1::WxpayController < Api::V1::ApplicationController
  def notify
    query_params = params.except(*request.path_parameters.keys)
    post_params = query_params.delete("xml")
    wp_print("wxpay_params: #{query_params}")
    if Wxpay::Notify.verify?(query_params, post_params)
      @order = Order.where(out_id: query_params["out_trade_no"]).lock(true).first
      return render text: "success" if @order.already_paid?
      if query_params["trade_state"].to_s == "0"
        # 是否需要跑两步，先从 pending 到 paid, 再直接从 paid 到 success ？
        @order.pre_pay!({payment_type: 'wxpay', trade_id: query_params["transaction_id"]})

        # 更新 tickets 状态
        @order.success_pay!

        wp_print("after order: #{@order}, #{@order.attributes}")
      end
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
