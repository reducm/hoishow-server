class AddEmailConfirmColumnToBoomAdmins < ActiveRecord::Migration
  def change
    add_column :boom_admins, :email_confirmed, :boolean, default: false
    add_column :boom_admins, :confirm_token, :string
  end
end
