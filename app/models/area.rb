class Area < ActiveRecord::Base
  belongs_to :stadium

  has_many :show_area_relations
  has_many :shows, through: :show_area_relations
  has_many :tickets
  has_many :seats

  validates :stadium, presence: {message: "Stadium不能为空"}

  paginates_per 20
end
