class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :email
      t.string :name
      t.string :encrypted_password
      t.string :salt
      t.datetime :last_sign_in_at
      t.integer :admin_type

      t.timestamps null: false
    end
  end
end
