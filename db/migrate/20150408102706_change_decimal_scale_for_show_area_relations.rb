class ChangeDecimalScaleForShowAreaRelations < ActiveRecord::Migration
  def up
    change_column :show_area_relations, :price, :decimal, precision:6, scale: 2
  end

  def down
    change_column :show_area_relations, :price, :decimal, precision:6
  end
end
