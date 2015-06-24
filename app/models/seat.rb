class Seat < ActiveRecord::Base
  serialize :channels

  belongs_to :show
  belongs_to :area
  belongs_to :order

  enum status: {
    avaliable: 0,  #可选
    locked: 1, #不可选
    unused: 2 #空白
  }

  scope :avaliable_seats, -> { where(status: statuses[:avaliable]) }
end
