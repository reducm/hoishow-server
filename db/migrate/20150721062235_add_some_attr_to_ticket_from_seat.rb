class AddSomeAttrToTicketFromSeat < ActiveRecord::Migration
  def change
    add_column :tickets, :row, :integer
    add_column :tickets, :column, :integer
    add_column :tickets, :channel, :string
  end
end
