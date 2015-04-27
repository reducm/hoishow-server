class Comment < ActiveRecord::Base
  CREATOR_USER = 'User'
  CREATOR_STAR = 'Star'
  CREATOR_ADMIN = 'Admin'

  belongs_to :topic
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  paginates_per 20

  def self.create_comment(subject, content)
    create!(subject_type: subject.class.name, subject_id: subject.id, content: content)
  end

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, comment_id: #{ id }, subject_type: #{topic.subject_type}, subject_id: #{topic.subject_id}")
      nil
    end
  end

  def parent
    Comment.where(id: parent_id).first
  end

  def creator_name
    if creator.is_a?(User)
      creator.show_name
    elsif creator.is_a?(Star) || creator.is_a?(Admin)
      creator.name
    end
  end

  def subject
    begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, comment_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
    end
  end
end
