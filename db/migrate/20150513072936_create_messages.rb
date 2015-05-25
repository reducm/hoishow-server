class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :type
      t.string :title
      t.text :content
      t.string :subject_type
      t.integer :subject_id
      t.string :creator_type
      t.integer :creator_id

      t.timestamps null: false
    end
  end
end
