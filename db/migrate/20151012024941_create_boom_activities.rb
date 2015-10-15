class CreateBoomActivities < ActiveRecord::Migration
  def change
    create_table :boom_activities do |t|
      t.string :boom_id
      t.string :boom_recommend_id
      t.string :boom_page_id
      t.string :boom_status_id
      t.string :url_share
      t.string :url
      t.string :cover
      t.string :owner
      t.string :name
      t.string :publisher
      t.string :file
      t.integer :tag_visible_number
      t.text :description
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_activities, :boom_id
    add_index :boom_activities, :name

    File.open(File.join(Rails.root, 'db', 'boombox', 'music_set_item.json'), 'r') do |file|
      BoomActivity.transaction do
        file.each do |line|
          b_json = JSON.parse line
          BoomActivity.create(
            boom_id: b_json['_id']['$oid'],
            boom_status_id: b_json['status']['$oid'],
            url: b_json['url'],
            url_share: b_json['url_share'],
            cover: b_json['cover'],
            name: b_json['name'],
            owner: b_json['owner'],
            publisher: b_json['publisher'],
            file: b_json['file'],
            tag_visible_number: b_json['tag_visible_number'],
            description: b_json['description'],
            removed: b_json['removed'],
            created_at: b_json['date_creation']['$date'].to_time
          )

          b_json['location'].each do |item|
            location = BoomLocation.where(boom_id: item['$oid']).first
            location.update(boom_activity_id: b_json['_id']['$oid']) if location
          end

          b_json['tag_relationship'].each do |item|
            relation = TagRelationship.where(boom_id: item['$oid']).first
            relation.update(boom_activity_id: b_json['_id']['$oid']) if relation
          end

          b_json['tracks'].each do |item|
            track = BoomTrack.where(boom_id: item['$oid']).first
            track.update(boom_activity_id: b_json['_id']['$oid']) if track
          end
        end
      end if Rails.env.production? || Rails.env.staging?
    end
  end
end
