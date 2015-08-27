class AddTicketInfoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ticket_info, :string
  end
end
