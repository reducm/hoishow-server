class AddColumnIsNewToUserMessagesRelations < ActiveRecord::Migration
  def up 
    add_column :user_message_relations, :is_new, :boolean, default: true
  end

  def down 
    remove_column :user_message_relations, :is_new
  end
end
