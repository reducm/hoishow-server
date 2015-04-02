class CreateUserLikeTopics < ActiveRecord::Migration
  def change
    create_table :user_like_topics do |t|
      t.integer :user_id
      t.integer :topic_id

      t.timestamps null: false
    end
  end
end
