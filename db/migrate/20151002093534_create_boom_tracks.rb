class CreateBoomTracks < ActiveRecord::Migration
  def change
    create_table :boom_tracks do |t|
      t.string :boom_id
      t.string :boom_activity_id
      t.string :name
      t.string :publisher
      t.string :file
      t.decimal :duration, precision: 12, scale: 6
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_tracks, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'track.json'), 'r') do |file|
      BoomTrack.transaction do
        file.each do |line|
          t_json = JSON.parse line
          BoomTrack.create(
            boom_id: t_json['_id']['$oid'],
            name: t_json['name'],
            publisher: t_json['publisher'],
            duration: t_json['duration'],
            removed: t_json['removed'],
            created_at: t_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
