#encoding: UTF-8
class Area < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.day)

  belongs_to :stadium

  has_many :show_area_relations, dependent: :destroy
  has_many :shows, through: :show_area_relations
  has_many :tickets
  with_options dependent: :destroy do |option|
    option.has_many :seats, -> { where(order_id: nil) }
  end

  validates :stadium, presence: {message: "场馆不能为空"}

  paginates_per 10
end
