#encoding: UTF-8
class Star < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)

  include ModelAttrI18n
  has_many :videos, dependent: :destroy
  has_many :user_follow_stars
  has_many :followers, through: :user_follow_stars, source: :user

  has_many :star_concert_relations
  has_many :concerts, through: :star_concert_relations

  has_many :topics, -> { where subject_type: Topic::SUBJECT_STAR }, :foreign_key => 'subject_id'

  validates :name, presence: {message: "姓名不能为空"}
  scope :is_display, -> { where(is_display: true) }

  mount_uploader :avatar, ImageUploader
  mount_uploader :poster, ImageUploader

  paginates_per 10

  def create_token
    self.token = SecureRandom.urlsafe_base64 if self.token.blank?
  end

  def vote_count
    concerts.map{|concert| concert.voters_count}.inject(&:+) || 0
  end

  def status_cn
    if concerts.count > 0 && shows.count > 0
      "开售中"
    else
      "无演出"
    end
  end

  def is_display_cn
    # is_display ? "显示" : "不显示"
    tran("is_display")
  end

  def hoi_concert(concert)
    star_concert_relations.where(concert: concert).first_or_create!
  end

  def followers_count
    followers.count
  end

  def shows
    Show.where(concert_id: concerts.pluck(:id))
  end

  class << self
    def search(q)
      where("name like ?", "%#{q}%")
    end
  end
end
