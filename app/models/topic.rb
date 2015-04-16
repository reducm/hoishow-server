#encoding: UTF-8
class Topic < ActiveRecord::Base
  belongs_to :city
  validates :creator_id, presence: true
  validates :creator_type, presence: true
  validates :subject_type, presence: true
  validates :content, presence: true
  validates :subject_id, presence: true
  validate :check_city_id
  has_many :comments


  has_many :user_like_topics
  has_many :likers, through: :user_like_topics, source: :user

  paginates_per 20

  def subject
     begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, topic_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
     end
  end

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, topic_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
    end
  end

  def creator_name
    if creator.is_a?(User)
      creator.show_name
    elsif creator.is_a?(Star)
      creator.name
    end
  end

  def is_like(user)
    ids = user_like_topics.pluck(:user_id)
    user.id.in?(ids) rescue false
  end

  def like_count
    user_like_topics.count
  end

  private
  def check_city_id
    errors[:city_id] << "subject Concert should have city_id!" if subject_type == Concert.name && city_id.blank?
  end
end
