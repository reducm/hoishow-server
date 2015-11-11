class AddLowerStringToBoomTags < ActiveRecord::Migration
  def up 
    add_column :boom_tags, :lower_string, :string
  end

  def down
    remove_column :boom_tags, :lower_string
  end
end
