#encoding: UTF-8
class Comment < ActiveRecord::Base
  default_scope {order('created_at DESC')}

  CREATOR_USER = 'User'
  CREATOR_STAR = 'Star'
  CREATOR_ADMIN = 'Admin'

  belongs_to :topic
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  paginates_per 10

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("creator wrong, comment_id: #{id}, creator_type: #{creator_type}, creator_id: #{creator_id}")
      nil
    end
  end

  def parent
    Comment.where(id: parent_id).first
  end

  def creator_name
    if creator.is_a?(User)
      creator.show_name
    elsif creator.is_a?(Admin)
      creator.default_name
    elsif creator.is_a?(Star)
      creator.name
    end
  end

  def subject
    begin
      Object::const_get(topic.subject_type).where(id: topic.subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, comment_id: #{ id }, subject_type: #{topic.subject_type}, subject_id: #{topic.subject_id}")
      nil
    end
  end
end
