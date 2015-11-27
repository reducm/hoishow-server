class ChangeBoomMessagesColumn < ActiveRecord::Migration
  def change
    remove_column :boom_messages, :notification_text, :string
    add_column :boom_messages, :status, :integer
  end
end
