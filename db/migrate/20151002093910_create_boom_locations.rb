class CreateBoomLocations < ActiveRecord::Migration
  def change
    create_table :boom_locations do |t|
      t.string :boom_id
      t.string :boom_city_id
      t.string :boom_activity_id
      t.string :boom_city_activity_page_id
      t.string :boom_city_page_id
      t.string :name
      t.string :name_english
      t.string :name_chinese
      t.string :phone
      t.string :weibo
      t.string :wechat
      t.decimal :longitude, precision: 10, scale: 6
      t.decimal :latitude, precision: 10, scale: 6
      t.string :address
      t.string :image
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_locations, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'location.json'), 'r') do |file|
      BoomLocation.transaction do
        file.each do |line|
          l_json = JSON.parse line
          city_id = l_json['city'].nil? ? '' : l_json['city']['$oid']
          BoomLocation.create(
            boom_id: l_json['_id']['$oid'],
            boom_city_id: city_id,
            name: l_json['name'],
            name_english: l_json['name_english'],
            name_chinese: l_json['name_chinese'],
            phone: l_json['phone'],
            weibo: l_json['weibo_sina'],
            wechat: l_json['wechat'],
            longitude: l_json['longitude'],
            latitude: l_json['latitude'],
            address: l_json['address'],
            image: l_json['images'][0],
            removed: l_json['removed'],
            created_at: l_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
