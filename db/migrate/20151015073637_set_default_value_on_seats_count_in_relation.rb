class SetDefaultValueOnSeatsCountInRelation < ActiveRecord::Migration
  def up
    change_column_default :show_area_relations, :seats_count, 0
  end

  def down 
    change_column :show_area_relations, :seats_count, :integer
  end
end
