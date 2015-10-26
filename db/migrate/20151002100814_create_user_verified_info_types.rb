class CreateUserVerifiedInfoTypes < ActiveRecord::Migration
  def change
    create_table :user_verified_info_types do |t|
      t.string :boom_id
      t.string :code
      t.string :name
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :user_verified_info_types, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'user_verified_type.json'), 'r') do |file|
      UserVerifiedInfoType.transaction do
        file.each do |line|
          u_json = JSON.parse line
          UserVerifiedInfoType.create(
            boom_id: u_json['_id']['$oid'],
            code: u_json['code'],
            name: u_json['name'],
            value: u_json['value'],
            removed: u_json['removed'],
            created_at: u_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
