class CreateActivityStatuses < ActiveRecord::Migration
  def change
    create_table :activity_statuses do |t|
      t.string :boom_id
      t.string :name
      t.string :code
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :activity_statuses, :boom_id
  end
end
