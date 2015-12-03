class CreateUserVerifiedInfos < ActiveRecord::Migration
  def change
    create_table :user_verified_infos do |t|
      t.string :boom_id
      t.string :boom_city_id
      t.string :boom_type_id
      t.string :name
      t.string :name_english
      t.string :name_chinese
      t.string :phone
      t.string :address
      t.string :contact_name
      t.string :contact_phone_number
      t.string :contact_address
      t.text :description
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :cover
      t.string :avatar
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :user_verified_infos, :boom_id
  end
end
