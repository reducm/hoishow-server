class AddTaskIdToMessages < ActiveRecord::Migration
  def up
    add_column :messages, :task_id, :string
  end
  def down
    remove_column :messages, :task_id
  end

end
