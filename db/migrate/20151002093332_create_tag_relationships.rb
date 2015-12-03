class CreateTagRelationships < ActiveRecord::Migration
  def change
    create_table :tag_relationships do |t|
      t.string :boom_id
      t.string :boom_tag_id
      t.string :boom_tag_sort_id
      t.string :boom_activity_id
      t.string :boom_page_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :tag_relationships, :boom_id
  end
end
