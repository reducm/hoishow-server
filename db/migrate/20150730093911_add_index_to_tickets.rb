class AddIndexToTickets < ActiveRecord::Migration
  def change
    add_index :tickets, [:seat_type, :status, :show_id, :area_id]
  end
end
