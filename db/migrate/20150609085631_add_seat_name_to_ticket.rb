class AddSeatNameToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :seat_name, :string
  end
end
