class AddSomeAttrToTicketFromSeat < ActiveRecord::Migration
  def up
    add_column :tickets, :row, :integer
    add_column :tickets, :column, :integer
    add_column :tickets, :channels, :string
    change_column_default :tickets, :status, 0
  end

  def down
    remove_column :tickets, :row, :integer
    remove_column :tickets, :column, :integer
    remove_column :tickets, :channels, :string
    change_column_default :tickets, :status, nil
  end
end
