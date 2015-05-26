class CreateExpresses < ActiveRecord::Migration
  def change
    create_table :expresses do |t|
      t.integer :user_id
      t.string :user_name
      t.string :user_address
      t.string :user_mobile

      t.timestamps null: false
    end
  end
end
