class ChangeDecimalScaleForShows < ActiveRecord::Migration
  def up
    change_column :shows, :min_price, :decimal, precision: 10, scale: 2
    change_column :shows, :max_price, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :shows, :min_price, :decimal, precision: 10 
    change_column :shows, :max_price, :decimal, precision: 10 
  end


end
