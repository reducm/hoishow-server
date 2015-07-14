class RenameBillIdInOrder < ActiveRecord::Migration
  def change
    rename_column :orders, :bill_id, :open_trade_no
  end
end
