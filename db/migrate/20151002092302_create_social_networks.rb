class CreateSocialNetworks < ActiveRecord::Migration
  def change
    create_table :social_networks do |t|
      t.string :boom_id
      t.string :boom_type_id
      t.string :boom_user_id
      t.string :contact
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :social_networks, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'social_network.json'), 'r') do |file|
      SocialNetwork.transaction do
        file.each do |line|
          s_json = JSON.parse line
          SocialNetwork.create(
            boom_id: s_json['_id']['$oid'],
            boom_type_id: s_json['type']['$oid'],
            contact: s_json['contact'],
            removed: s_json['removed'],
            created_at: s_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
