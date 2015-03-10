class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :url
      t.references :star, index: true
      t.references :concert, index: true

      t.timestamps null: false
    end
  end
end
