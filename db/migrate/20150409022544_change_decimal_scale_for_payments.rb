class ChangeDecimalScaleForPayments < ActiveRecord::Migration
  def up
    change_column :payments, :amount, :decimal, precision: 10, scale: 2
    change_column :payments, :refund_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :payments, :amount, :decimal, precision: 10 
    change_column :payments, :refund_amount, :decimal, precision: 10 
  end


end
