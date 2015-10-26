class CreateTagRelationships < ActiveRecord::Migration
  def change
    create_table :tag_relationships do |t|
      t.string :boom_id
      t.string :boom_tag_id
      t.string :boom_tag_sort_id
      t.string :boom_activity_id
      t.string :boom_page_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :tag_relationships, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'tag_relationship.json'), 'r') do |file|
      TagRelationship.transaction do
        file.each do |line|
          t_json = JSON.parse line
          TagRelationship.create(
            boom_id: t_json['_id']['$oid'],
            boom_tag_id: t_json['tag_item']['$oid'],
            boom_tag_sort_id: t_json['tag_sort']['$oid'],
            removed: t_json['removed'],
            created_at: t_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
