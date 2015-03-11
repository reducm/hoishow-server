class AddSeatsInfoToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :seats_info, :string
  end

  def down
    remove_column :orders, :seats_info
  end
end
