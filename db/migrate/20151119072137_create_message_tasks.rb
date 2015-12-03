class CreateMessageTasks < ActiveRecord::Migration
  def change
    create_table :message_tasks do |t|
      t.integer :boom_message_id
      t.string :task_id
      t.string :platform
      t.integer :status
      t.integer :total_count

      t.timestamps null: false
    end
  end
end
