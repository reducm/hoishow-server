class AddEventUrlIdToShows < ActiveRecord::Migration
  def change
    add_column :shows, :event_url_id, :string
  end
end
