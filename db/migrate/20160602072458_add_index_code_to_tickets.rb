class AddIndexCodeToTickets < ActiveRecord::Migration
  def change
    add_index :tickets, :code
  end
end
