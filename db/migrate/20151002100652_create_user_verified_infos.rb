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

    File.open(File.join(Rails.root, 'db', 'boombox', 'user_verified_info.json'), 'r') do |file|
      UserVerifiedInfo.transaction do
        file.each do |line|
          u_json = JSON.parse line
          city_id = u_json['city_id'].nil? ? '' : u_json['city_id']['$oid']
          type_id = u_json['type'].nil? ? '' : u_json['type']['$oid']
          UserVerifiedInfo.create(
            boom_id: u_json['_id']['$oid'],
            boom_city_id: city_id,
            boom_type_id: type_id,
            name: u_json['name'],
            name_english: u_json['name_english'],
            name_chinese: u_json['name_chinese'],
            phone: u_json['phone'],
            address: u_json['address'],
            contact_name: u_json['contact_name'],
            contact_phone_number: u_json['contact_phone_number'],
            contact_address: u_json['contact_address'],
            description: u_json['description'],
            longitude: u_json['longitude'],
            latitude: u_json['latitude'],
            cover: u_json['cover'],
            avatar: u_json['avatar'],
            removed: u_json['removed'],
            created_at: u_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
