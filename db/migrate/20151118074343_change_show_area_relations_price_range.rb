class ChangeShowAreaRelationsPriceRange < ActiveRecord::Migration
  def change
    change_column :show_area_relations, :price, :decimal, precision: 10, scale: 2
  end
end
