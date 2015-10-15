class CreateBoomComments < ActiveRecord::Migration
  def change
    create_table :boom_comments do |t|
      t.integer :boom_topic_id
      t.integer :parent_id
      t.integer :creator_id
      t.string :creator_type
      t.string :avatar
      t.text :content

      t.timestamps null: false
    end
  end
end
