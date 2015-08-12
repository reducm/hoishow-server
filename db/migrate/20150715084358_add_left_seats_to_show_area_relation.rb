class AddLeftSeatsToShowAreaRelation < ActiveRecord::Migration
  def up
    add_column :show_area_relations, :left_seats, :integer, default: 0
    remove_index :show_area_relations, :area_id
    remove_index :show_area_relations, :show_id
    add_index :show_area_relations, [:show_id, :area_id]
  end

  def down
    remove_column :show_area_relations, :left_seats, :integer
    add_index :show_area_relations, :area_id
    add_index :show_area_relations, :show_id
    remove_index :show_area_relations, [:show_id, :area_id]
  end
end
