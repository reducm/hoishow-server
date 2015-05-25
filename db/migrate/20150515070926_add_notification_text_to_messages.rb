class AddNotificationTextToMessages < ActiveRecord::Migration
  def up
    add_column :messages, :notification_text, :string
  end

  def down
    remove_column :messages, :notification_text
  end

end
