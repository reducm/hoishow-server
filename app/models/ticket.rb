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

  scope :sold_tickets, ->{where("status = ? or status = ?", statuses[:success], statuses[:used])}
  scope :avaliable_tickets, ->{where(status: statuses[:pending], seat_type: seat_types[:avaliable])}
  after_save :generate_code, unless: :pending?
  after_create :set_seat_type

  paginates_per 10

  def self.area_sold_tickets_count(area_id)
    where("area_id = ? and (status = ? or status = ?)", area_id, statuses[:success], statuses[:used]).count
  end

  def self.area_unpaid_tickets_count(area_id)
    where("area_id = ? and status = ?", area_id, statuses[:pending]).count
  end

  def self.outdate_tickets
    success.select{|i| i.area.show_time && i.area.show_time < Time.now.beginning_of_day - 2.days}
  end

  def seat_key
    [self.row, self.column].join('|')
  end

  protected
  def generate_code
    if self.code.blank? && self.order.ticket_type == 'e_ticket'
      loop do
        code = SecureRandom.hex(4)
        unless Ticket.where(code: code).exists?
          self.update(code: code)
          break
        end
      end
    end
  end

  def search(q)
    where("nickname like ? or mobile like ?", "%#{q}%", "%#{q}%")
  end

  def set_seat_type
    self.seat_type = 0 if seat_type.nil?
    self.save
  end

  private
  # is a seat ?
  def is_a_seat?
    is_a? Seat
  end
end
