class ChangeValidTimeToDatetimeToOrders < ActiveRecord::Migration
  def up
    change_column :orders, :valid_time, :datetime
  end

  def down
    change_column :orders, :valid_time, :string
  end
end
