class CreateStars < ActiveRecord::Migration
  def change
    create_table :stars do |t|
      t.string :name
      t.string :avatar

      t.timestamps null: false
    end
  end
end
