class RemoveAreaInfoFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :area_name 
    remove_column :orders, :area_id
  end

  def down
    add_column :orders, :area_name, :string 
    add_column :orders, :area_id, :integer
  end
end
