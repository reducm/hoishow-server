class CreateBoomUserStatuses < ActiveRecord::Migration
  def change
    create_table :boom_user_statuses do |t|
      t.string :boom_id
      t.string :name
      t.string :code
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_user_statuses, :boom_id
  end
end
