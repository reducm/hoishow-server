class AddSeatTypeToShow < ActiveRecord::Migration
  def change
    add_column :shows, :seat_type, :integer
  end
end
