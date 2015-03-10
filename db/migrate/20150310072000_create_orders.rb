class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.decimal :amount
      t.string :concert_name
      t.string :stadium_name
      t.string :area_name
      t.string :show_name
      t.string :valid_time
      t.string :out_id, index: true
      t.string :city_name
      t.string :star_name
      t.references :user, index: true
      t.integer :concert_id
      t.integer :city_id
      t.integer :stadium_id
      t.integer :star_id
      t.integer :area_id
      t.integer :show_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
