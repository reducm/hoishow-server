module Boombox::Operation::ApplicationHelper
  def get_datetime(value)
    value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
  end

  def get_date(value)
    value.nil? ? nil : value.to_date
  end

  def boombox_subject_redirect_url(subject_type, id)
    subject = get_subject(subject_type)
    if subject_type == 'Collaborator'
      Rails.application.routes.url_helpers.send("boombox_operation_#{subject}_path", id)
    else
      Rails.application.routes.url_helpers.send("edit_boombox_operation_#{subject}_path", id)
    end
  end

  def get_subject(type)
    case type
    when 'BoomPlaylist'
      'playlist'
    when 'BoomActivity'
      'activity'
    else
      type.downcase
    end
  end
end
