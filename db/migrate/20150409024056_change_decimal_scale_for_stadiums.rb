class ChangeDecimalScaleForStadiums < ActiveRecord::Migration
  def up
    change_column :stadiums, :longitude, :decimal, precision: 10, scale: 6
    change_column :stadiums, :latitude, :decimal, precision: 10, scale: 6
  end

  def down
    change_column :stadiums, :longitude, :decimal, precision: 10 
    change_column :stadiums, :latitude, :decimal, precision: 10 
  end


end
