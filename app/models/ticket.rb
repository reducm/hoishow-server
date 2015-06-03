#encoding: UTF-8
class Ticket < ActiveRecord::Base
  default_scope {order('created_at DESC')}

  STATUS_PENDING = 0
  STATUS_SUCCESS = 1
  STATUS_USED = 2
  STATUS_REFUND = 3

  belongs_to :area
  belongs_to :show
  belongs_to :order
  belongs_to :admin

  validates :area, presence: true
  validates :show, presence: true
  validates :order, presence: true

  enum status: {
    pending: 0, #未支付时没有code
    success: 1, #可用
    used: 2, #已用
    refund: 3 #退款
  }

  scope :sold_tickets, ->{ where("status != ?", statuses[:pending] ) }
  before_create :set_status

  paginates_per 10

  def self.sold_tickets_count
    sold_tickets.count
  end

  def generate_code
    if self.code.blank?
      loop do
        code = SecureRandom.hex(4)
        if Ticket.where(code: code).blank?
          self.update_attributes({
            code: code
          })
          break
        end
      end
    end
    self.code
  end

  protected
  def set_status
    self.status = :pending if self.status.blank?
  end

  def search(q)
    where("nickname like ? or mobile like ?", "%#{q}%", "%#{q}%")
  end
end
