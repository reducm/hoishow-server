class AddIdentityToCollaborator < ActiveRecord::Migration
  def up 
    add_column :collaborators, :identity, :integer
  end

  def down 
    remove_column :collaborators, :identity
  end
end
