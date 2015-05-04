class Stadium < ActiveRecord::Base
  has_many :areas
  has_many :shows
  belongs_to :city

  validates :name, presence: {message: "Name不能为空"}
  validates :city, presence: {message: "City不能为空"}

  mount_uploader :pic, ImageUploader
  paginates_per 20
end
