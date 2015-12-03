class AddTargetsAndStartTimeToBoomMessages < ActiveRecord::Migration
  def change
    add_column :boom_messages, :targets, :integer
    add_column :boom_messages, :start_time, :datetime
  end
end
