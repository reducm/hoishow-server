class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.decimal :min_pirce
      t.decimal :max_price
      t.string :poster
      t.string :name
      t.datetime :show_time
      t.references :concert, index: true
      t.references :city, index: true
      t.references :stadium, index: true

      t.timestamps null: false
    end
  end
end
