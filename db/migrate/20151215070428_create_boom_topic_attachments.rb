class CreateBoomTopicAttachments < ActiveRecord::Migration
  def change
    create_table :boom_topic_attachments do |t|
      t.integer :boom_topic_id
      t.string :image

      t.timestamps null: false
    end
  end
end
