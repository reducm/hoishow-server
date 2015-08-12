class AddStadiumMapToShow < ActiveRecord::Migration
  def change
    add_column :shows, :stadium_map, :string
  end
end
