class AddTicketPathToEvents < ActiveRecord::Migration
  def change
    add_column :events, :ticket_path, :string
  end
end
