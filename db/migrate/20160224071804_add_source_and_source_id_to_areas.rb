class AddSourceAndSourceIdToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :source, :integer
    add_column :areas, :source_id, :integer
  end
end
