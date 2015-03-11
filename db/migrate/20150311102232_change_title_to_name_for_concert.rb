class ChangeTitleToNameForConcert < ActiveRecord::Migration
  def up
    rename_column :concerts, :title, :name
  end

  def down
    rename_column :concerts, :name, :title
  end
end
