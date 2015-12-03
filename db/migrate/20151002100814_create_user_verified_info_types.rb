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
  end
end
