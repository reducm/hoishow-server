class AddIsTopToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :is_top, :boolean, default: false
  end
end
