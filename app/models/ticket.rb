#encoding: UTF-8
class Ticket < ActiveRecord::Base
  default_scope {order('created_at DESC')}

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
    refund: 3, #退款
    outdate: 4 #超时
  }

  scope :sold_tickets, ->{ where("status = ? or status = ?", statuses[:success], statuses[:used] ) }
  scope :unpaid_tickets, ->{ where("status = ? or status = ?", statuses[:pending], statuses[:outdate] ) }
  before_create :set_status
  before_save :generate_code, unless: :pending?

  paginates_per 10

  protected
  def set_status
    self.status = :pending if self.status.blank?
  end

  def generate_code
    if self.code.blank?
      loop do
        code = SecureRandom.hex(4)
        unless Ticket.where(code: code).exists?
          self.update_attributes({
            code: code
          })
          break
        end
      end
    end
    self.code
  end

  def search(q)
    where("nickname like ? or mobile like ?", "%#{q}%", "%#{q}%")
  end
end
