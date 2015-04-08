class RemoveStarNameStarIdFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :star_id
    remove_column :orders, :star_name
  end

  def down
    add_column :orders, :star_id, :integer
    add_column :orders, :star_name, :string
  end

end
