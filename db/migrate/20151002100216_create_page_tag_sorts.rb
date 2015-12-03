class CreatePageTagSorts < ActiveRecord::Migration
  def change
    create_table :page_tag_sorts do |t|
      t.string :boom_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_tag_sorts, :boom_id
  end
end
