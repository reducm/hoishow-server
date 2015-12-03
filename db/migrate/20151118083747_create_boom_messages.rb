class CreateBoomMessages < ActiveRecord::Migration
  def change
    create_table :boom_messages do |t|
      t.integer :boom_admin_id
      t.integer :subject_id
      t.integer :send_type
      t.string :subject_type
      t.string :title
      t.string :notification_text
      t.text :content

      t.timestamps null: false
    end
  end
end
