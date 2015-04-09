class ChangeDecimalScaleForOrders < ActiveRecord::Migration
  def up
    change_column :orders, :amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :orders, :amount, :decimal, precision: 10 
  end

end
