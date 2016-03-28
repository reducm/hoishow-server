class AddBuyPriceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :buy_price, :decimal, precision: 10, scale: 2
  end
end
