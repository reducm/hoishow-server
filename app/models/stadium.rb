#encoding: UTF-8
class Stadium < ActiveRecord::Base
  has_many :areas
  has_many :shows
  belongs_to :city

  validates :name, presence: {message: "场馆名字不能为空"}
  validates :city, presence: {message: "城市不能为空"}

  mount_uploader :pic, ImageUploader
  paginates_per 10
end
