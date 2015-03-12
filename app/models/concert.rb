class Concert < ActiveRecord::Base
  has_many :videos
  has_many :shows

  has_many :user_follow_concerts
  has_many :followers, through: :user_follow_concerts, source: :user

  has_many :concert_city_relations
  has_many :cities, through: :concert_city_relations

  validates :name, presence: {message: "演唱会名不能为空"}
end
