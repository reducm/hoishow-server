class ChangeSeats < ActiveRecord::Migration
  def change
    add_column :seats, :row, :integer
    add_column :seats, :column, :integer
    add_column :seats, :status, :integer
    add_column :seats, :name, :string
    add_column :seats, :price, :decimal, precision: 10, scale: 2

    add_index :seats, [:show_id, :area_id]
  end
end
