class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :subject
      t.integer :subject_id
      t.text :content
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
