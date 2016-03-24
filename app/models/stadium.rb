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

  enum source: {
    hoishow: 0, # 自有资源
    damai: 1, # 大麦
    yongle: 2, # 永乐
    weipiao: 3 # 微票
  }
end
