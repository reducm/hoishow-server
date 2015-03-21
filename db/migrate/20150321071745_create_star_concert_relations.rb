class CreateStarConcertRelations < ActiveRecord::Migration
  def change
    create_table :star_concert_relations do |t|
      t.references :star, index: true
      t.references :concert, index: true

      t.timestamps null: false
    end
  end
end
