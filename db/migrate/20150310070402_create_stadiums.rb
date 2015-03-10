class CreateStadiums < ActiveRecord::Migration
  def change
    create_table :stadiums do |t|
      t.string :name
      t.string :address
      t.decimal :longitude
      t.decimal :latitude
      t.references :city, index: true

      t.timestamps null: false
    end
  end
end
