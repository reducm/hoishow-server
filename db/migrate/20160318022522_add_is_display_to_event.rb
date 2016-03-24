class AddIsDisplayToEvent < ActiveRecord::Migration
  def change
    add_column :events, :is_display, :boolean, default: true
  end
end
