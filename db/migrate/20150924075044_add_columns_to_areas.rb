class AddColumnsToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :coordinates, :text
    add_column :areas, :color, :string
    add_column :areas, :event_id, :integer
    add_index :areas, :event_id
  end
end
