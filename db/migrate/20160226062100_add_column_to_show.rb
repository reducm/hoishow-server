class AddColumnToShow < ActiveRecord::Migration
  def change
    add_column :shows, :yl_play_city_id, :integer
    add_column :shows, :yl_fconfig_id, :integer
  end
end
