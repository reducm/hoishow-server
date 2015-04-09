class AddSeatsCountToShowAreaRelations < ActiveRecord::Migration
  def up
    add_column :show_area_relations, :seats_count, :integer
  end
   
  def down
    remove_column :show_area_relations, :seats_count
  end

end
