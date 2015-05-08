class AddColumnAdminIdToTickets < ActiveRecord::Migration
  def up
    add_column :tickets, :admin_id, :integer
  end

  def down
    remove_column :tickets, :admin_id
  end

end
