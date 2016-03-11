class AddPriceRangeAndBuyPriceToShowAreaRelations < ActiveRecord::Migration
  def change
    add_column :show_area_relations, :price_range, :string
  end
end
