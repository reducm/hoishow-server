class AddTicketPicAndDescribeTimeToShows < ActiveRecord::Migration
  def up
    add_column :shows, :Ticket_pic, :string
    add_column :shows, :description_time, :string
  end

  def down 
    remove_column :shows, :Ticket_pic
    remove_column :shows, :description_time
  end
end
