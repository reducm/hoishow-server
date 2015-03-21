class Concert < ActiveRecord::Base
  has_many :videos
  has_many :shows

  has_many :user_follow_concerts
  has_many :followers, through: :user_follow_concerts, source: :user

  has_many :concert_city_relations
  has_many :cities, through: :concert_city_relations

  has_many :star_concert_relations
  has_many :stars, through: :star_concert_relations

  validates :name, presence: {message: "演唱会名不能为空"}

  has_many :comments, :class_name => "Comment", :foreign_key => 'subject_id'

  def followers_count
    followers.count
  end

  def comments_count
    comments.count
  end

  def shows_count
    shows.count
  end
end
