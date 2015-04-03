class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  validates :user_id, presence: true

  def self.create_comment(subject, content)
    create!(subject_type: subject.class.name, subject_id: subject.id, content: content)
  end

  def subject
    begin
      Object::const_get(subject_type).where(id: subject_id).first 
    rescue 
      Rails.logger.fatal("subject wrong, comment_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
    end
  end
end
