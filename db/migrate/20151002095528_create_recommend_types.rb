class CreateRecommendTypes < ActiveRecord::Migration
  def change
    create_table :recommend_types do |t|
      t.string :boom_id
      t.string :name
      t.string :code
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :recommend_types, :boom_id
  end
end
