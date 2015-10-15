class CreateActivityVerifieds < ActiveRecord::Migration
  def change
    create_table :activity_verifieds do |t|
      t.string :boom_id
      t.string :url
      t.string :cover
      t.string :name
      t.string :publisher
      t.string :file
      t.integer :tag_visible_number
      t.text :description
      t.boolean :verified
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :activity_verifieds, :boom_id
    add_index :activity_verifieds, :name

    File.open(File.join(Rails.root, 'db', 'boombox', 'set_item_upload.json'), 'r') do |file|
      ActivityVerified.transaction do
        file.each do |line|
          a_json = JSON.parse line
          ActivityVerified.create(
            boom_id: a_json['_id']['$oid'],
            url: a_json['url'],
            cover: a_json['cover'],
            name: a_json['name'],
            verified: a_json['verified'],
            publisher: a_json['publisher'],
            file: a_json['file'],
            tag_visible_number: a_json['tag_visible_number'],
            description: a_json['description'],
            removed: a_json['removed'],
            created_at: a_json['date_creation']['$date'].to_time
          )

          a_json['location'].each do |item|
            location = BoomLocation.where(boom_id: item['$oid']).first
            location.update(boom_activity_id: a_json['_id']['$oid']) if location
          end

          a_json['tag_relationship'].each do |item|
            relation = TagRelationship.where(boom_id: item['$oid']).first
            relation.update(boom_activity_id: a_json['_id']['$oid']) if relation
          end

          a_json['tracks'].each do |item|
            track = BoomTrack.where(boom_id: item['$oid']).first
            track.update(boom_activity_id: a_json['_id']['$oid']) if track
          end
        end
      end if Rails.env.production? || Rails.env.staging?
    end
  end
end
