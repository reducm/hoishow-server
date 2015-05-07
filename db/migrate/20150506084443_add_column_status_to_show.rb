class AddColumnStatusToShow < ActiveRecord::Migration
  def up
    add_column :shows, :status, :integer
  end

  def down
    remove_column :shows, :status
  end

end
