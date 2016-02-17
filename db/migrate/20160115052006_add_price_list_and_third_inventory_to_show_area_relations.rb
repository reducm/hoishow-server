class AddPriceListAndThirdInventoryToShowAreaRelations < ActiveRecord::Migration
  def change
    add_column :show_area_relations, :price_range, :string
    add_column :show_area_relations, :third_inventory, :integer
  end
end
