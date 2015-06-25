class AddApiTokenToAdmins < ActiveRecord::Migration
  def up
    add_column :admins, :api_token, :string
  end

  def down
    remove_column :admins, :api_token 
  end
end
