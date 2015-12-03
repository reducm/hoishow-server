class CreateBoomUserMessageRelations < ActiveRecord::Migration
  def change
    create_table :boom_user_message_relations do |t|
      t.integer :user_id
      t.integer :boom_message_id

      t.timestamps null: false
    end
  end
end
