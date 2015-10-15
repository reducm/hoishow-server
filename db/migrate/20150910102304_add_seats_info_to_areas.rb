class AddSeatsInfoToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :seats_info, :text, limit: 1.megabytes
  end
end
