class RenameExpiresInToApiExpiresInToUsers < ActiveRecord::Migration
  def up
    rename_column :users, :expires_in, :api_expires_in
  end

  def down
    rename_column :users, :api_expires_in, :expires_in
  end

end
