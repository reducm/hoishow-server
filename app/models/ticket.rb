class Ticket < ActiveRecord::Base
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
  }

  scope :sold_tickets, ->{ where("status != ?", statuses[:pending] ) }
  before_create :set_status

  paginates_per 20

  def self.sold_tickets_count
    sold_tickets.count
  end

  protected
  def set_status
    self.status = :pending
  end

  def generate_code
    if self.code.blank?
      loop do
        random_num = Time.now.to_ms
        code = id.to_s(16) + random_num.to_s(16)
        if Coupon.where(code: code).blank?
          self.update_attributes({
            code: code
          })
          break
        end
      end
    end
    self.code
  end
end
