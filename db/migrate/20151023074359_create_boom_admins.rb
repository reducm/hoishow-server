class CreateBoomAdmins < ActiveRecord::Migration
  def up 
    create_table :boom_admins do |t|
      t.string :email
      t.string :name
      t.string :encrypted_password
      t.string :salt
      t.datetime :last_sign_in_at
      t.integer :admin_type
      t.boolean :is_block, default: false 
      t.string :api_token

      t.timestamps null: false
    end
  end

  def down
    drop_table :boom_admins 
  end
end
