#encoding: UTF-8
class ShowAreaRelation < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.hour)
  serialize :channels

  belongs_to :show
  belongs_to :area

  validates :show, presence: {message: "演出不能为空"}
  validates :area, presence: {message: "区域不能为空"}
  validates_uniqueness_of :show_id, scope: [:area_id]
  validates :left_seats, {numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: :seats_count}}
  #validates :left_seats, {numericality: {greater_than_or_equal_to: 0}}

  # is_sold_out method warpper
  def is_sold_out
    self.left_seats <= 0
  end
end
