module Operation::ApplicationHelper
  def get_datetime(value)
    value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
  end

  def get_date(value)
    value.nil? ? nil : value.to_date
  end
end
