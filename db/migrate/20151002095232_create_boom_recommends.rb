class CreateBoomRecommends < ActiveRecord::Migration
  def change
    create_table :boom_recommends do |t|
      t.string :boom_id
      t.string :boom_type_id
      t.string :boom_page_id
      t.string :title
      t.string :subtitle
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_recommends, :boom_id
  end
end
