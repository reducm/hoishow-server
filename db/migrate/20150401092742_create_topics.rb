class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :creator_type
      t.integer :creator_id
      t.string :subject_type
      t.integer :subject_id
      t.text :content
      t.boolean :is_top, default: false
      t.integer :city_id

      t.timestamps null: false
    end
  end
end
