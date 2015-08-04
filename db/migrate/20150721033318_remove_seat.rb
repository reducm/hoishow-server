class RemoveSeat < ActiveRecord::Migration
  def up
    # migrate seats data to tickets
    drop_table :seats
  end

  def down
    create_table :seats do |t|
      t.integer :show_id
      t.integer :area_id
      t.integer :status
      t.integer :row
      t.integer :column
      t.integer :status
      t.string :name
      t.decimal :price,  precision: 10, scale: 2
      t.integer :order_id
      t.string :channels

      t.timestamps null: false
    end

    add_index :seats, [:show_id, :area_id]
  end
end
