class CreateActivityStatuses < ActiveRecord::Migration
  def change
    create_table :activity_statuses do |t|
      t.string :boom_id
      t.string :name
      t.string :code
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :activity_statuses, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'music_set_item_status.json'), 'r') do |file|
      ActivityStatus.transaction do
        file.each do |line|
          a_json = JSON.parse line
          ActivityStatus.create(
            boom_id: a_json['_id']['$oid'],
            name: a_json['name'],
            code: a_json['code'],
            value: a_json['value'],
            removed: a_json['removed'],
            created_at: a_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
