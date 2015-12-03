class CreateBoomCities < ActiveRecord::Migration
  def change
    create_table :boom_cities do |t|
      t.string :boom_id
      t.string :boom_page_id
      t.string :name
      t.string :name_english
      t.string :name_chinese
      t.string :cover
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_cities, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'city.json'), 'r') do |file|
      BoomCity.transaction do
        file.each do |line|
          c_json = JSON.parse line
          BoomCity.create(
            boom_id: c_json['_id']['$oid'],
            name: c_json['name'],
            name_english: c_json['name_english'],
            name_chinese: c_json['name_chinese'],
            cover: c_json['cover'],
            removed: c_json['removed'],
            created_at: c_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
