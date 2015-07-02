#encoding: UTF-8
class Payment < ActiveRecord::Base

  belongs_to :order

  enum status: {
    pending: 0, #待支付
    success: 1, #支付成功
    refund: 2 #已退款
  }

  def purchase
    begin
     Object::const_get(purchase_type).where(id: purchase_id).first
   rescue => e
     ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
     Rails.logger.fatal("purcharse wrong, payment_id: #{ id }, purchase_type: #{purchase_type}, purchase_id: #{purchase_id}")
     nil
    end
  end
end
