class AddRemarkToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :remark, :text
  end

  def down 
    remove_column :orders, :remark
  end
end
