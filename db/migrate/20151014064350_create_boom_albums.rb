class CreateBoomAlbums < ActiveRecord::Migration
  def change
    create_table :boom_albums do |t|
      t.integer :collaborator_id
      t.string :image

      t.timestamps null: false
    end

    add_index :boom_albums, :collaborator_id
  end
end
