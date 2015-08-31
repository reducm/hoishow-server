class CreateHelps < ActiveRecord::Migration
  def up 
    create_table :helps do |t|
      t.string :name
      t.text :description
      t.integer :position

      t.timestamps null: false
    end
  end

  def down
    drop_table :helps 
  end
end
