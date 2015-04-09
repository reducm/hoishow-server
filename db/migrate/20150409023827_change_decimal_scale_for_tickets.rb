class ChangeDecimalScaleForTickets < ActiveRecord::Migration
  def up
    change_column :tickets, :price, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :tickets, :price, :decimal, precision: 10 
  end


end
