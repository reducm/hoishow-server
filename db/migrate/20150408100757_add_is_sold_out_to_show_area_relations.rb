class AddIsSoldOutToShowAreaRelations < ActiveRecord::Migration
  def up
    add_column :show_area_relations, :is_sold_out, :boolean, default: false
  end

  def down
    remove_column :show_area_relations, :is_sold_out
  end
end
