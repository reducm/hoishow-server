class CreatePageLocations < ActiveRecord::Migration
  def change
    create_table :page_locations do |t|
      t.string :boom_id
      t.string :boom_music_top_id
      t.string :boom_location_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_locations, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'page_location.json'), 'r') do |file|
      PageLocation.transaction do
        file.each do |line|
          p_json = JSON.parse line
          music_top_id = p_json['music_top'].blank? ? '' : p_json['music_top'][0]['$oid']
          location_id = p_json['location'].nil? ? '' : p_json['location']['$oid']
          PageLocation.create(
            boom_id: p_json['_id']['$oid'],
            boom_location_id: location_id,
            boom_music_top_id: music_top_id,
            removed: p_json['removed'],
            created_at: p_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
