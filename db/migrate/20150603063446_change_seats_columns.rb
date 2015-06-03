class ChangeSeatsColumns < ActiveRecord::Migration
  def change
    remove_column :seats, :row
    remove_column :seats, :column
    add_column :seats, :name, :string
    add_column :seats, :seats_info, :string
  end
end
