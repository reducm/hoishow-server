class RemoveSeatsInfoFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :seats_info
  end

  def down 
    remove_column :orders, :seats_info, :string
  end

end
