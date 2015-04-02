class AddParentIdToComments < ActiveRecord::Migration
  def up
    add_column :comments, :parent_id, :integer
  end

  def down
    remove_column :comments, :parent_id, :integer
  end
end
