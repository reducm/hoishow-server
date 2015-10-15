class BoomComment < ActiveRecord::Base
  belongs_to :boom_topic
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("creator wrong, boom_comment_id: #{id}, creator_type: #{creator_type}, creator_id: #{creator_id}")
      nil
    end
  end
end
