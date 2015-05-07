class AddColumnIsShowToConcert < ActiveRecord::Migration
  def up
    add_column :concerts, :is_show, :boolean
  end

  def down
    remove_column :concerts, :is_show
  end

end
