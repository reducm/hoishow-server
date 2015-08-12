class CreateSeats < ActiveRecord::Migration
  def change
    create_table :seats do |t|
      t.integer :show_id
      t.integer :area_id
      t.integer :status
      t.integer :row
      t.integer :column

      t.timestamps null: false
    end
  end
end
