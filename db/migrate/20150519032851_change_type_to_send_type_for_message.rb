class ChangeTypeToSendTypeForMessage < ActiveRecord::Migration
  def up
    rename_column :messages, :type, :send_type
  end
  
  def down
    rename_column :messages, :send_type, :type
  end

end
