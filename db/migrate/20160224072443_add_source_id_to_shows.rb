class AddSourceIdToShows < ActiveRecord::Migration
  def change
    add_column :shows, :source_id, :integer
    add_column :shows, :yl_play_address_id, :integer
    add_column :shows, :yl_play_type_a_id, :integer
    add_column :shows, :yl_play_type_b_id, :integer
  end
end
