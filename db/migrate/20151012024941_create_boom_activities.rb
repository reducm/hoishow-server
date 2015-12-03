class CreateBoomActivities < ActiveRecord::Migration
  def change
    create_table :boom_activities do |t|
      t.string :boom_id
      t.string :boom_recommend_id
      t.string :boom_page_id
      t.string :boom_status_id
      t.string :url_share
      t.string :url
      t.string :cover
      t.string :owner
      t.string :name
      t.string :publisher
      t.string :file
      t.integer :tag_visible_number
      t.text :description
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_activities, :boom_id
    add_index :boom_activities, :name
  end
end
