class AddSourceNameToShows < ActiveRecord::Migration
  def change
    add_column :shows, :source_name, :string
  end
end
