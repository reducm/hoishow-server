class CreatePageCities < ActiveRecord::Migration
  def change
    create_table :page_cities do |t|
      t.string :boom_id
      t.string :boom_city_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_cities, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'page_city.json'), 'r') do |file|
      PageCity.transaction do
        file.each do |line|
          p_json = JSON.parse line
          city_id = p_json['city'].nil? ? '' : p_json['city']['$oid']
          PageCity.create(
            boom_id: p_json['_id']['$oid'],
            boom_city_id: city_id,
            removed: p_json['removed'],
            created_at: p_json['date_creation']['$date'].to_time
          )
          p_json['location'].each do |item|
            BoomLocation.where(boom_id: item['$oid']).first.update(boom_city_page_id: p_json['_id']['$oid'])
          end

          p_json['location_top'].each do |item|
            BoomLocation.where(boom_id: item['$oid']).first.update(boom_city_page_id: p_json['_id']['$oid'])
          end
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
