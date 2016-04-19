class AddETicketSmsToShow < ActiveRecord::Migration
  def up 
    add_column :shows, :e_ticket_sms, :string
  end

  def down 
    remove_column :shows, :e_ticket_sms
  end
end
