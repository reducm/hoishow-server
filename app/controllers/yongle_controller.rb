class YongleController < ApplicationController
  before_action :validate_encrypt

  def refund
    result = @order.notify_refund
    if result["result"] == 'success'
      @order.yongle_refunds!({handle_ticket_method: 'refund'})
      return response_msg(200, '成功')
    else
      return response_msg(500, '服务异常')
    end
  end

  private
  def validate_encrypt
    str = Digest::MD5.hexdigest "#{YongleSetting['key']}#{params[:unionOrderId]}"
    return response_msg(108, '加密串验证失败') unless str == params[:encryptStr]

    @order = Order.where(out_id: params[:unionOrderId]).first
    @order.sync_yongle_status
    @order.reload
    case
    when @order.nil?
      return response_msg(109, 'id不存在')
    when @order.refund?
      return response_msg(108, '订单已退款不能重复退款')
    when !@order.refunding?
      return response_msg(108, '支付状态不对')
    end
  end

  def response_msg(return_code, context)
    data = {returnCode: return_code, returnDesc: context}.to_xml(root: 'Response', skip_types: true)
    render xml: data
  end
end
