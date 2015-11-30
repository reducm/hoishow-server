class RemoveBoomAdminIdFromBoomMessages < ActiveRecord::Migration
  def change
    remove_column :boom_messages, :boom_admin_id
  end
end
