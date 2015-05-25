class CreateStartups < ActiveRecord::Migration
  def change
    create_table :startups do |t|
      t.string :pic
      t.datetime :valid_time
      t.boolean :is_display, default: false

      t.timestamps null: false
    end
  end
end
