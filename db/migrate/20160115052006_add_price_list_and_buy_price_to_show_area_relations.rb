class AddPriceListAndThirdInventoryToShowAreaRelations < ActiveRecord::Migration
  def change
    add_column :show_area_relations, :price_range, :string
    add_column :show_area_relations, :buy_price, :decimal, precision: 10, scale: 2
  end
end
