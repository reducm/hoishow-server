class AddDescriptionTimeAndEndTimeAndIsMultiDayToEvents < ActiveRecord::Migration
  def change
    add_column :events, :description_time, :string
    add_column :events, :end_time, :datetime
    add_column :events, :is_multi_day, :boolean, default: false
  end
end
