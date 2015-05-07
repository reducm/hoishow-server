class ChangeIsShowToIntegerForConcerts < ActiveRecord::Migration
  def up
    change_column :concerts, :is_show, :integer
  end

  def down
    change_column :concerts, :is_show, :boolean
  end
end
