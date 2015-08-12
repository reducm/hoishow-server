class AddOutTradeNoAndBuyOriginToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :out_trade_no, :string
    add_column :orders, :buy_origin, :string
  end
end
