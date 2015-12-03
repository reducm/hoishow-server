class CreateRecommendPages < ActiveRecord::Migration
  def change
    create_table :recommend_pages do |t|
      t.string :boom_id
      t.integer :visible_number
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :recommend_pages, :boom_id
  end
end
