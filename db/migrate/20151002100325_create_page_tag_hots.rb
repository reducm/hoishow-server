class CreatePageTagHots < ActiveRecord::Migration
  def change
    create_table :page_tag_hots do |t|
      t.string :boom_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_tag_hots, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'page_tag_hot.json'), 'r') do |file|
      PageTagHot.transaction do
        file.each do |line|
          p_json = JSON.parse line
          PageTagHot.create(
            boom_id: p_json['_id']['$oid'],
            removed: p_json['removed'],
            created_at: p_json['date_creation']['$date'].to_time
          )
          p_json['tag'].each do |item|
            TagHot.where(boom_id: item['$oid']).first.update(boom_page_id: p_json['_id']['$oid'])
          end
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
