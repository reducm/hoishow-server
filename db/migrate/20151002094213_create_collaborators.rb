class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.string :boom_id
      t.string :boom_collaborator_type_id
      t.string :name
      t.string :email
      t.string :contact
      t.string :weibo
      t.string :cover
      t.string :wechat
      t.text :description
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :collaborators, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'collaborator.json'), 'r') do |file|
      Collaborator.transaction do
        file.each do |line|
          c_json = JSON.parse line
          Collaborator.create(
            boom_id: c_json['_id']['$oid'],
            boom_collaborator_type_id: c_json['type']['$oid'],
            name: c_json['name'],
            email: c_json['email'],
            contact: c_json['contact'],
            weibo: c_json['weibo'],
            wechat: c_json['wechat'],
            description: c_json['description'],
            removed: c_json['removed'],
            created_at: c_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
