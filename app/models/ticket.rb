class Ticket < ActiveRecord::Base
  belongs_to :area
  belongs_to :show
  belongs_to :order

  validates :area, presence: true
  validates :show, presence: true
  validates :order, presence: true

  enum status: {
    pending: 0, #未支付时没有code
    success: 1, #可用
    used: 2, #已用
  }

  before_create :set_status

  paginates_per 20

  protected
  def set_status
    self.status = :pending
  end
end
