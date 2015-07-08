class CreateSimditorImages < ActiveRecord::Migration
  def change
    create_table :simditor_images do |t|
      t.string :image, null: false

      t.timestamps null: false
    end
  end
end
