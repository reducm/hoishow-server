class AddColumnCheckedAtToTickets < ActiveRecord::Migration
  def up
    add_column :tickets, :checked_at, :datetime
  end

  def down
    remove_column :tickets, :checked_at
  end
end
