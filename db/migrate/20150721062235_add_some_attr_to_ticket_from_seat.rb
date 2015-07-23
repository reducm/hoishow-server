class AddSomeAttrToTicketFromSeat < ActiveRecord::Migration
  def change
    add_column :tickets, :row, :integer
    add_column :tickets, :column, :integer
    add_column :tickets, :channels, :string
    change_column_default :tickets, :status, 0
  end
end
