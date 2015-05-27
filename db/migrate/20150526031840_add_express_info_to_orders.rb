class AddExpressInfoToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :express_id, :string
    add_column :orders, :user_address, :string
    add_column :orders, :user_name, :string
    add_column :orders, :user_mobile, :string
  end

  def down
    remove_column :orders, :express_id
    remove_column :orders, :user_address
    remove_column :orders, :user_mobile
    remove_column :orders, :user_name
  end
end
