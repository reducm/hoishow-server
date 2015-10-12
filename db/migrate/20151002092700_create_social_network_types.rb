class CreateSocialNetworkTypes < ActiveRecord::Migration
  def change
    create_table :social_network_types do |t|
      t.string :boom_id
      t.string :name
      t.string :code
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :social_network_types, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'social_network_type.json'), 'r') do |file|
      SocialNetworkType.transaction do
        file.each do |line|
          s_json = JSON.parse line
          SocialNetworkType.create(
            boom_id: s_json['_id']['$oid'],
            name: s_json['name'],
            code: s_json['code'],
            value: s_json['value'],
            removed: s_json['removed'],
            created_at: s_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
