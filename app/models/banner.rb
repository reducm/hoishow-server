#encoding: UTF-8
class Banner < ActiveRecord::Base
  belongs_to :admin
  mount_uploader :poster, ImageUploader

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
    case subject_type
    when "Star"
      "明星"
    when "Concert"
      "投票"
    when "Show"
      "演出"
    when "Article"
      "图文"
    end
  end

  def is_article?
    subject_type == "Article"
  end
end
