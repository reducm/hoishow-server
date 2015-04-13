class Concert < ActiveRecord::Base
  has_many :videos
  has_many :shows

  has_many :user_follow_concerts
  has_many :followers, through: :user_follow_concerts, source: :user

  has_many :user_vote_concerts
  has_many :voters, through: :user_vote_concerts, source: :user

  has_many :concert_city_relations
  has_many :cities, through: :concert_city_relations

  has_many :star_concert_relations
  has_many :stars, through: :star_concert_relations

  validates :name, presence: {message: "演唱会名不能为空"}

  has_many :topics, :class_name => "Topic", :foreign_key => 'subject_id'


  paginates_per 20

  enum status: {
    voting: 0,
    finished: 1
  }

  mount_uploader :poster, PosterUploader 

  def followers_count
    followers.count
  end

  def status_cn
    case status
    when "voting"
      "投票中"
    when "finished"
      "投票完结"
    end
  end

  def votedate_cn
    "#{ start_date.strfcn_date }~#{ end_date.strfcn_date }"
  end

  def shows_count
    shows.count
  end

  def voters_count
    voters.count
  end

end
