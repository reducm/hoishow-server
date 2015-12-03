class AddBoomAdminIdToCollaborator < ActiveRecord::Migration
  def up
    add_column :collaborators, :boom_admin_id, :integer
  end

  def down 
    remove_column :collaborators, :boom_admin_id
  end
end
