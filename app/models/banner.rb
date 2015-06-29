#encoding: UTF-8
class Banner < ActiveRecord::Base
  include ModelAttrI18n
  default_scope {order(:position)}
  belongs_to :admin
  mount_uploader :poster, ImageUploader

  validates :subject_id, presence: true
  validates :subject_type, presence: true
  validates :position, uniqueness: true
  before_create :set_position_for_new_record

  def set_position_for_new_record
    self.position = Banner.maximum("position").to_i + 1
  end

  def subject
     begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, banner_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
     end
  end

  def subject_name
    subject.name rescue "图文主体"
  end

  def subject_type_cn
    # Star: "明星"
    # Concert: "投票"
    # Show: "演出"
    # Article: "图文"
    tran("subject_type")
  end

  def is_article?
    subject_type == "Article"
  end
end
