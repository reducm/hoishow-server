class CreateRecommendPages < ActiveRecord::Migration
  def change
    create_table :recommend_pages do |t|
      t.string :boom_id
      t.integer :visible_number
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :recommend_pages, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'recommend_page.json'), 'r') do |file|
      RecommendPage.transaction do
        file.each do |line|
          r_json = JSON.parse line
          type_id = r_json['type'].nil? ? '' : r_json['type']['$oid']
          RecommendPage.create(
            boom_id: r_json['_id']['$oid'],
            visible_number: r_json['visible_number'],
            removed: r_json['removed'],
            created_at: r_json['date_creation']['$date'].to_time
          )
          r_json['column'].each do |item|
            BoomRecommend.where(boom_id: item['$oid']).first.update(boom_page_id: r_json['_id']['$oid'])
          end
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
