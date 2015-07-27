class ChangeSeatsInfoSeats < ActiveRecord::Migration
  def change
    change_column :seats, :seats_info, :text
    remove_column :seats, :status
    remove_column :seats, :name
  end
end
