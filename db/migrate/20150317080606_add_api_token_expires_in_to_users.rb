class AddApiTokenExpiresInToUsers < ActiveRecord::Migration
  def up
    add_column :users, :api_token, :string
    add_column :users, :expires_in, :integer
  end

  def down
    remove_column :users, :api_token
    remove_column :users, :expires_in
  end
end
