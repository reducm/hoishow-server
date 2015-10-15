class CreateBoomTopics < ActiveRecord::Migration
  def change
    create_table :boom_topics do |t|
      t.string :created_by
      t.string :avatar
      t.string :subject_type
      t.integer :subject_id
      t.text :content

      t.timestamps null: false
    end
  end
end
