class AddStatusToTickets < ActiveRecord::Migration
  def up
    add_column :tickets, :status, :integer
  end
   
  def down
    remove_column :tickets, :status
  end
end
