class CreateUserMessageRelations < ActiveRecord::Migration
  def change
    create_table :user_message_relations do |t|
      t.references :user, index: true
      t.references :message, index: true

      t.timestamps null: false
    end
  end
end
