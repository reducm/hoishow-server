class CreateBoomArticles < ActiveRecord::Migration
  def change
    create_table :boom_articles do |t|
      t.string :boom_id
      t.string :boom_location_id
      t.string :title
      t.string :subtitle
      t.string :url_alias
      t.string :url_short
      t.string :url_origin
      t.string :cover
      t.string :summary
      t.text :content_html
      t.text :content_json
      t.boolean :verified
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_articles, :boom_id
  end
end
