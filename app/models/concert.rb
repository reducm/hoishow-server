#encoding: UTF-8
class Concert < ActiveRecord::Base
  include ModelAttrI18n
  default_scope {order('concerts.is_top DESC, concerts.created_at DESC')}

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

  has_many :topics, -> { where subject_type: Topic::SUBJECT_CONCERT }, :foreign_key => 'subject_id'

  scope :showing_concerts, ->{ where("is_show = ?", is_shows[:showing]) }
  scope :concerts_without_auto_hide, ->{ where("is_show != ?", is_shows[:auto_hide]) }

  paginates_per 10

  enum status: {
    voting: 0,
    finished: 1
  }

  enum is_show: {
    showing: 0,
    hidden: 1,
    auto_hide: 2
  }

  mount_uploader :poster, ImageUploader

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["演出艺人", "投票名称", "投票状态", "显示状态", "投票时间范围", "演出数量", "投票数量", "关注数量"]
      all.each do |c|
        csv << [c.stars.pluck(:name).join(","), c.name, c.status_cn, c.is_show_cn, c.description_time, c.shows.count, c.voters_count, c.followers_count]
      end
    end
  end

  def poster_url
    if poster.url.present?
      if Rails.env.production?
        poster.url("800")
      else
        poster.url
      end
    else
      nil
    end
  end

  def followers_count
    followers.count
  end

  def is_show_cn
    # showing: "显示中"
    # hidden: "隐藏中"
    tran("is_show")
  end

  def status_cn
    # voting: "投票中"
    # finished: "投票完结"
    tran("status")
  end

  def shows_count
    shows.count
  end

  def voters_count
    voters.count
  end

  def get_voters_count_with_base_number
    self.voters_count + self.concert_city_relations.sum(:base_number)
  end
end
