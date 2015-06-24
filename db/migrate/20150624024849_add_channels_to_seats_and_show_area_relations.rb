class AddChannelsToSeatsAndShowAreaRelations < ActiveRecord::Migration
  def change
    add_column :seats, :channels, :string
    add_column :show_area_relations, :channels, :string
  end
end
