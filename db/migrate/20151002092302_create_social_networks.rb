class CreateSocialNetworks < ActiveRecord::Migration
  def change
    create_table :social_networks do |t|
      t.string :boom_id
      t.string :boom_type_id
      t.string :boom_user_id
      t.string :contact
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :social_networks, :boom_id
  end
end
