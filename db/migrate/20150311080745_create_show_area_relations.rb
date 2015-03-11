class CreateShowAreaRelations < ActiveRecord::Migration
  def change
    create_table :show_area_relations do |t|
      t.references :show, index: true
      t.references :area, index: true
      t.decimal :price

      t.timestamps null: false
    end
  end
end
