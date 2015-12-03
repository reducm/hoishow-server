class CreatePageCityActivities < ActiveRecord::Migration
  def change
    create_table :page_city_activities do |t|
      t.string :boom_id
      t.string :boom_activity_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_city_activities, :boom_id
  end
end
