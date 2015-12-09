class AddBoomboxDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :boom_id, :string
    add_column :users, :boom_status_id, :string
    add_column :users, :boom_verified_info_id, :string
    add_column :users, :removed, :boolean
    add_column :users, :description, :text
  end
end
