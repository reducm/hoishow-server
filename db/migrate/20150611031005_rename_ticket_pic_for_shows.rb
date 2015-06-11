class RenameTicketPicForShows < ActiveRecord::Migration
  def up
    rename_column :shows, :Ticket_pic, :ticket_pic
  end

  def down
    rename_column :shows, :ticket_pic, :Ticket_pic
  end
end
