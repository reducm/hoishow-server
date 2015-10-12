class CreateTagHots < ActiveRecord::Migration
  def change
    create_table :tag_hots do |t|
      t.string :boom_id
      t.string :boom_page_id
      t.string :name
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :tag_hots, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'tag_hot.json'), 'r') do |file|
      TagHot.transaction do
        file.each do |line|
          t_json = JSON.parse line
          TagHot.create(
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
