class CreateConcertCityRelations < ActiveRecord::Migration
  def change
    create_table :concert_city_relations do |t|
      t.references :concert, index: true
      t.references :city, index: true

      t.timestamps null: false
    end
  end
end
