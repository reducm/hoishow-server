class AddTicketTypeToShows < ActiveRecord::Migration
  def up
    add_column :shows, :ticket_type, :integer
  end

  def down
    remove_column :shows, :ticket_type
  end


end
