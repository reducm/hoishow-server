class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :name
      t.integer :seats_count
      t.references :stadium, index: true

      t.timestamps null: false
    end
  end
end
