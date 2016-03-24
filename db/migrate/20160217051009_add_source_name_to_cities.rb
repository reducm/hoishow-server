class AddSourceNameToCities < ActiveRecord::Migration
  def change
    add_column :cities, :source_name, :string
  end
end
