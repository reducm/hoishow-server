class AddTicketPicToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ticket_pic, :string
  end
end
