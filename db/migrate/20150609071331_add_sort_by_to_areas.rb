class AddSortByToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :sort_by, :string
  end
end
