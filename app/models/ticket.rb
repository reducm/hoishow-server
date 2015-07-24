#encoding: UTF-8
class Ticket < ActiveRecord::Base
  serialize :channels

  belongs_to :area
  belongs_to :show
  belongs_to :order
  belongs_to :admin

  validates :area, presence: true
  validates :show, presence: true
  validates :order, presence: true, unless: :is_a_seat?

  enum status: {
    pending: 0, # 演出生成
    success: 1, # 出票成功
    used: 2,    # 已检票
    refund: 3,  # 退款
    outdate: 4, # 超时
  }

  # 为了兼容以前的 seat 表
  enum seat_type: {
    avaliable: 0,  # 可选
    locked: 1,     # 不可选
    unused: 2      # 空白座位
  }

  scope :sold_tickets, ->{ where("status = ? or status = ?", statuses[:success], statuses[:used] ) }
  scope :unpaid_tickets, ->{ where("status = ? or status = ?", statuses[:pending], statuses[:outdate] ) }
  before_save :generate_code, unless: :pending?

  paginates_per 10

  protected
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

  private
  # is a seat ?
  def is_a_seat?
    is_a? Seat
  end
end
