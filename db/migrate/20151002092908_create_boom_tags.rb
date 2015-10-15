class CreateBoomTags < ActiveRecord::Migration
  def change
    create_table :boom_tags do |t|
      t.string :boom_id
      t.string :name
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_tags, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'tag_item.json'), 'r') do |file|
      BoomTag.transaction do
        file.each do |line|
          t_json = JSON.parse line
          BoomTag.create(
            boom_id: t_json['_id']['$oid'],
            name: t_json['name'],
            removed: t_json['removed'],
            created_at: t_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
