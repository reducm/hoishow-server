class CreateApiAuths < ActiveRecord::Migration
  def change
    create_table :api_auths do |t|
      t.string :key
      t.string :user

      t.timestamps null: false
    end
  end
end
