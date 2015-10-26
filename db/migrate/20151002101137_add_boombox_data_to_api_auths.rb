class AddBoomboxDataToApiAuths < ActiveRecord::Migration
  def change
    add_column :api_auths, :boom_id, :string
    add_column :api_auths, :verified, :boolean

    File.open(File.join(Rails.root, 'db', 'boombox', 'api_auth.json'), 'r') do |file|
      ApiAuth.transaction do
        file.each do |line|
          a_json = JSON.parse line
          ApiAuth.create(
            boom_id: a_json['_id']['$oid'],
            user: a_json['name'],
            verified: a_json['verified'],
            key: a_json['key'],
            secretcode: a_json['secret'],
            created_at: a_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
