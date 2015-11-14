class AddAvatarToCollaborator < ActiveRecord::Migration
  def up 
    add_column :collaborators, :avatar, :string
  end

  def down 
    remove_column :collaborators, :avatar
  end
end
