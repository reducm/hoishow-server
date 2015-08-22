class AddTicketTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ticket_type, :integer
  end
end
