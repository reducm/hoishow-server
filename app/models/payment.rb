#encoding: UTF-8
class Payment < ActiveRecord::Base

  enum status: {
    pending: 0, #待支付
    success: 1, #支付成功
    refund: 2 #已退款
  }

  def purchase
    model = Object::const_get(purchase_type)
    obj = Object::const_get(purchase_type).find_by_id(purchase_id)
  end
end
