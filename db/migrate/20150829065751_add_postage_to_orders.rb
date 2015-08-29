class AddPostageToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :postage, :decimal, precision: 4, scale: 2, default: 0.0
  end
end
