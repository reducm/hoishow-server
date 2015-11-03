class AddLeftSeatsToArea < ActiveRecord::Migration
  def change
    add_column :areas, :left_seats, :integer
  end
end
