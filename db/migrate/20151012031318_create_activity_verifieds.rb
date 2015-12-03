class CreateActivityVerifieds < ActiveRecord::Migration
  def change
    create_table :activity_verifieds do |t|
      t.string :boom_id
      t.string :url
      t.string :cover
      t.string :name
      t.string :publisher
      t.string :file
      t.integer :tag_visible_number
      t.text :description
      t.boolean :verified
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :activity_verifieds, :boom_id
    add_index :activity_verifieds, :name
  end
end
