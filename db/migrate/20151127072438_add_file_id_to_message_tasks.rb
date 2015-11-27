class AddFileIdToMessageTasks < ActiveRecord::Migration
  def change
    add_column :message_tasks, :file_id, :string
  end
end
