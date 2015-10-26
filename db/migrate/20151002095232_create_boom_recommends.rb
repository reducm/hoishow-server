class CreateBoomRecommends < ActiveRecord::Migration
  def change
    create_table :boom_recommends do |t|
      t.string :boom_id
      t.string :boom_type_id
      t.string :boom_page_id
      t.string :title
      t.string :subtitle
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_recommends, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'recommend_column.json'), 'r') do |file|
      BoomRecommend.transaction do
        file.each do |line|
          r_json = JSON.parse line
          type_id = r_json['type'].nil? ? '' : r_json['type']['$oid']
          BoomRecommend.create(
            boom_id: r_json['_id']['$oid'],
            boom_type_id: type_id,
            title: r_json['title'],
            subtitle: r_json['subtitle'],
            removed: r_json['removed'],
            created_at: r_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
