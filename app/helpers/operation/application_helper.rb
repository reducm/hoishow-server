module Operation::ApplicationHelper
  def get_datetime(value)
    value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
  end

  def get_date(value)
    value.nil? ? nil : value.to_date
  end

  def subject_show_url(subject_type, id)
    Rails.application.routes.url_helpers.send("opeeration_#{subject_type.downcase}_url", id) 
  end
end
