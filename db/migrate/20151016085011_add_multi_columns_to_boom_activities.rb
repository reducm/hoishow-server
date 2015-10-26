class AddMultiColumnsToBoomActivities < ActiveRecord::Migration
  def change
    add_column :boom_activities, :showtime, :string
    add_column :boom_activities, :boom_location_id, :integer
    add_column :boom_activities, :mode, :integer
    add_column :boom_activities, :boom_admin_id, :integer
  end
end
