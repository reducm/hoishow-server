class AddSeatTypeToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :seat_type, :integer, default: 0
  end
end
