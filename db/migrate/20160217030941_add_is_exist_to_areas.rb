class AddIsExistToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :is_exist, :boolean, default: true
  end
end
