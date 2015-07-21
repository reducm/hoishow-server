#encoding: UTF-8
class Area < ActiveRecord::Base
  belongs_to :stadium

  has_many :show_area_relations, dependent: :destroy
  has_many :shows, through: :show_area_relations
  has_many :tickets, dependent: :destroy
  has_many :seats, dependent: :destroy

  validates :stadium, presence: {message: "场馆不能为空"}

  paginates_per 10
end
