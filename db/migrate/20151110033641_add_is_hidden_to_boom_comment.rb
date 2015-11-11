class AddIsHiddenToBoomComment < ActiveRecord::Migration
  def up 
    add_column :boom_comments, :is_hidden, :boolean, default: false
  end

  def down
    remove_column :boom_comments, :is_hidden
  end
end
