class AddOrderIdToSeats < ActiveRecord::Migration
  def change
    add_column :seats, :order_id, :integer
  end
end
