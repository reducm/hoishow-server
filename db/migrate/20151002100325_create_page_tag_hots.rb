class CreatePageTagHots < ActiveRecord::Migration
  def change
    create_table :page_tag_hots do |t|
      t.string :boom_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_tag_hots, :boom_id
  end
end
