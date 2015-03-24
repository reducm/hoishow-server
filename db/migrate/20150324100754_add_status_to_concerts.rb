class AddStatusToConcerts < ActiveRecord::Migration
  def up
    add_column :concerts, :status, :integer
  end

  def down
    remove_column :concerts, :status
  end
end
