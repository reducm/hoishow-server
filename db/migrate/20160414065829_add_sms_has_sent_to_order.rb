class AddSmsHasSentToOrder < ActiveRecord::Migration
  def up 
    add_column :orders, :sms_has_been_sent, :boolean, default: false
  end

  def down
    remove_column :orders, :sms_has_been_sent
  end
end
