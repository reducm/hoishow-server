class CreateCollaboratorTypes < ActiveRecord::Migration
  def change
    create_table :collaborator_types do |t|
      t.string :boom_id
      t.string :code
      t.string :name
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :collaborator_types, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'collaborator_type.json'), 'r') do |file|
      CollaboratorType.transaction do
        file.each do |line|
          c_json = JSON.parse line
          CollaboratorType.create(
            boom_id: c_json['_id']['$oid'],
            code: c_json['code'],
            name: c_json['name'],
            value: c_json['value'],
            removed: c_json['removed'],
            created_at: c_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
