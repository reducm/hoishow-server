class AddIsBlockToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :is_block, :boolean, default: false
  end
end
