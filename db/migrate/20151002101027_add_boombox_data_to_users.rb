class AddBoomboxDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :boom_id, :string
    add_column :users, :boom_status_id, :string
    add_column :users, :boom_verified_info_id, :string
    add_column :users, :removed, :boolean
    add_column :users, :description, :text

    File.open(File.join(Rails.root, 'db', 'boombox', 'user.json'), 'r') do |file|
      User.transaction do
        file.each do |line|
          u_json = JSON.parse line
          verified_info_id = u_json['user_verified_info'].nil? ? '' : u_json['user_verified_info']['$oid']
          User.create(
            boom_id: u_json['_id']['$oid'],
            boom_status_id: u_json['status']['$oid'],
            boom_verified_info_id: verified_info_id,
            nickname: u_json['name'],
            email: u_json['email'],
            avatar: u_json['avatar'],
            description: u_json['description'],
            removed: u_json['removed'],
            created_at: u_json['date_creation']['$date'].to_time
          )

          u_json['social_network'].each do |item|
            SocialNetwork.where(boom_id: item['$oid']).first.update(boom_user_id: u_json['_id']['$oid'])
          end
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
