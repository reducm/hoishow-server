#encoding: UTF-8
class Payment < ActiveRecord::Base
  STATUS_PENDING = 0
  STATUS_SUCCESS = 1
  STATUS_REFUND = 2

  def purchase
    model = Object::const_get(purchase_type)
    obj = Object::const_get(purchase_type).find_by_id(purchase_id)
  end
end
