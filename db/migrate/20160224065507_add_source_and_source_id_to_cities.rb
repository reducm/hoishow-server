class AddSourceAndSourceIdToCities < ActiveRecord::Migration
  def change
    add_column :cities, :source, :integer
    add_column :cities, :source_id, :integer
    add_column :cities, :yl_fconfig_id, :integer
  end
end
