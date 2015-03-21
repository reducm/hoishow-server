class Stadium < ActiveRecord::Base
  has_many :areas
  belongs_to :city
  has_many :shows

  validates :name, presence: {message: "Name不能为空"}
  validates :city, presence: {message: "City不能为空"}
end
