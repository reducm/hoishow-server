class AddBoomboxDataToApiAuths < ActiveRecord::Migration
  def change
    add_column :api_auths, :boom_id, :string
    add_column :api_auths, :verified, :boolean
  end
end
