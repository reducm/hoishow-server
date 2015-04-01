class AddIndexNameToStars < ActiveRecord::Migration
  def up
    add_index :stars, :name
  end

  def down
    remove_index :stars, :name
  end
end
