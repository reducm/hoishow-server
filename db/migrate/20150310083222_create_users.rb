class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :mobile
      t.string :email
      t.string :encrypted_password
      t.datetime :last_sign_in_at
      t.string :avatar
      t.string :nickname
      t.integer :sex
      t.datetime :birthday
      t.string :salt
      t.boolean :has_set_password

      t.timestamps null: false
    end
  end
end
