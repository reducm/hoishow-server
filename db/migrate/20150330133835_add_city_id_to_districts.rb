class AddCityIdToDistricts < ActiveRecord::Migration
  def up 
    add_column :districts, :city_id, :integer
  end

  def down
    remove_column :districts, :city_id
  end


end
