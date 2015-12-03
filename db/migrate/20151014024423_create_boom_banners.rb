class CreateBoomBanners < ActiveRecord::Migration
  def change
    create_table :boom_banners do |t|
      t.string :poster
      t.string :subject_type
      t.integer :subject_id
      t.integer :position

      t.timestamps null: false
    end
  end
end
