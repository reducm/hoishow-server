# coding: utf-8
class Api::V1::WxpayController < Api::V1::ApplicationController
  def notify
    query_params = params.except(*request.path_parameters.keys)
    post_params = query_params.delete("xml")

    if Wxpay::Notify.verify?(query_params, post_params)
      @order = Order.where(out_id: query_params["out_trade_no"]).lock(true).first
      return render text: "success" if @order.already_paid?
      if query_params["trade_state"].to_s == "0"
        @order.update_attributes!(status: Order::ORDER_STATUS_PAID, pay_at: Time.now) if @order.pending?

        @payment = @order.wxpay_pay

        unless @payment.nil?
          @payment.update_attributes(
            trade_id: query_params["transaction_id"],
            status:   Payment::STATUS_SUCCESS,
            pay_at:   Time.now
          )
        end

        #TODO @order.pay_order_to_service
      end
      render text: "success"
    else
      render text: "fail"
    end
  end
end

