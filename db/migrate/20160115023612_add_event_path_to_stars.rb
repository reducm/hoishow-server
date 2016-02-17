class AddEventPathToStars < ActiveRecord::Migration
  def change
    add_column :stars, :event_path, :string
  end
end
