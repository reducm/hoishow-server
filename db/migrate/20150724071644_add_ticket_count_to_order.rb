class AddTicketCountToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :tickets_count, :integer
  end
end
