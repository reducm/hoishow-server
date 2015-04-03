class AddColumnTopicIdToComments < ActiveRecord::Migration
  def up
    add_column :comments, :topic_id, :integer 
  end

  def down
    remove_column :comments, :topic_id 
  end

end
