class AddSecretcodeToApiAuth < ActiveRecord::Migration
  def up 
    add_column :api_auths, :secretcode, :string
  end

  def down 
    remove_column :api_auths, :secretcode
  end
end
