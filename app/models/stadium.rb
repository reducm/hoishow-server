class Stadium < ActiveRecord::Base
  has_many :areas
  belongs_to :district
  has_many :shows

  validates :name, presence: {message: "Name不能为空"}
  validates :city, presence: {message: "City不能为空"}

  delegate :city, to: :district

  paginates_per 20
end
