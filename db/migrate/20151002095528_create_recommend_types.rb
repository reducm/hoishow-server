class CreateRecommendTypes < ActiveRecord::Migration
  def change
    create_table :recommend_types do |t|
      t.string :boom_id
      t.string :name
      t.string :code
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :recommend_types, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'recommend_column_type.json'), 'r') do |file|
      RecommendType.transaction do
        file.each do |line|
          r_json = JSON.parse line
          RecommendType.create(
            boom_id: r_json['_id']['$oid'],
            name: r_json['name'],
            code: r_json['code'],
            value: r_json['value'],
            removed: r_json['removed'],
            created_at: r_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
