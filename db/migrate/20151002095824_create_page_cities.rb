class CreatePageCities < ActiveRecord::Migration
  def change
    create_table :page_cities do |t|
      t.string :boom_id
      t.string :boom_city_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_cities, :boom_id
  end
end
