class AddChannelBillIdAndGenerateTicketTime < ActiveRecord::Migration
  def change
    add_column :orders, :channel, :integer
    add_column :orders, :bill_id, :string
    add_column :orders, :generate_ticket_at, :datetime
  end
end
