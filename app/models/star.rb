#encoding: UTF-8
class Star < ActiveRecord::Base
  include ModelAttrI18n
  default_scope {order(:position)}
  has_many :videos
  accepts_nested_attributes_for :videos, allow_destroy: true
  has_many :user_follow_stars
  has_many :followers, through: :user_follow_stars, source: :user

  has_many :star_concert_relations
  has_many :concerts, through: :star_concert_relations

  validates :name, presence: {message: "姓名不能为空"}
  validates :position, uniqueness: true
  validates_associated :videos

  has_many :topics, -> { where subject_type: Topic::SUBJECT_STAR }, :foreign_key => 'subject_id'

  scope :is_display, -> { where(is_display: true) }

  before_create :set_position_for_new_record

  mount_uploader :avatar, ImageUploader
  mount_uploader :poster, ImageUploader

  paginates_per 10

  def set_position_for_new_record
    self.position = Star.maximum("position").to_i + 1
  end

  def avatar_url
    if avatar.url.present?
      if Rails.env.production?
        avatar.url("avatar")
      else
        avatar.url
      end
    else
      nil
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

  def vote_count
    concerts.map{|concert| concert.voters_count}.inject(&:+) || 0
  end

  def status_cn
    if concerts.count > 0
      if shows.count > 0
        "开售中"
      else
        "投票中"
      end
    else
      "无演出"
    end
  end

  def is_display_cn
    if is_display
      "显示"
    else
      "不显示"
    end
    # tran("is_display")
  end

  def hoi_concert(concert)
    star_concert_relations.where(concert: concert).first_or_create!
  end

  def followers_count
    followers.count
  end

  def shows
    concert_ids = concerts.pluck(:id)
    Show.where(concert_id: concert_ids)
  end

  class << self
    def search(q)
      where("name like ?", "%#{q}%")
    end
  end
end
