#encoding: UTF-8
class Stadium < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)

  has_many :areas
  has_many :shows
  belongs_to :city

  validates :name, presence: {message: "场馆名字不能为空"}
  validates :city, presence: {message: "城市不能为空"}

  mount_uploader :pic, ImageUploader
  paginates_per 10
end
