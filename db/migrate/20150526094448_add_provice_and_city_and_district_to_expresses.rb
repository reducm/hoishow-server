class AddProviceAndCityAndDistrictToExpresses < ActiveRecord::Migration
  def up
    add_column :expresses, :province, :string
    add_column :expresses, :city, :string
    add_column :expresses, :district, :string
  end
  def down
    remove_column :expresses, :province
    remove_column :expresses, :city
    remove_column :expresses, :district
  end
end
