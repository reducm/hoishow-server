class CreatePageCityActivities < ActiveRecord::Migration
  def change
    create_table :page_city_activities do |t|
      t.string :boom_id
      t.string :boom_activity_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_city_activities, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'page_city_music_item.json'), 'r') do |file|
      PageCityActivity.transaction do
        file.each do |line|
          p_json = JSON.parse line
          PageCityActivity.create(
            boom_id: p_json['_id']['$oid'],
            boom_activity_id: p_json['music']['$oid'],
            removed: p_json['removed'],
            created_at: p_json['date_creation']['$date'].to_time
          )

          p_json['location'].each do |item|
            location = BoomLocation.where(boom_id: item['$oid']).first
            location.update(boom_city_activity_page_id: p_json['_id']['$oid']) if location
          end

          p_json['tag_relationship'].each do |item|
            relation = TagRelationship.where(boom_id: item['$oid']).first
            relation.update(boom_page_id: p_json['_id']['$oid']) if relation
          end

          p_json['city'].each do |item|
            city = BoomCity.where(boom_id: item['$oid']).first
            city.update(boom_page_id: p_json['_id']['$oid']) if city
          end
        end
      end if Rails.env.production? || Rails.env.staging?
    end
  end
end
