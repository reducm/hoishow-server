class CreateTagHots < ActiveRecord::Migration
  def change
    create_table :tag_hots do |t|
      t.string :boom_id
      t.string :boom_page_id
      t.string :name
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :tag_hots, :boom_id
  end
end
