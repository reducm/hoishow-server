class CreateBoomTags < ActiveRecord::Migration
  def change
    create_table :boom_tags do |t|
      t.string :boom_id
      t.string :name
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_tags, :boom_id
  end
end
