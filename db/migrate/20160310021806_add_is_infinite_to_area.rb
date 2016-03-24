class AddIsInfiniteToArea < ActiveRecord::Migration
  def change
    add_column :areas, :is_infinite, :boolean, default: false
  end
end
