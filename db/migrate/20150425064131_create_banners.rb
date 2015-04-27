class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.references :admin, index: true
      t.string :poster
      t.string :subject
      t.integer :subject_id
      t.text :description
      t.string :slogan

      t.timestamps null: false
    end
  end
end
