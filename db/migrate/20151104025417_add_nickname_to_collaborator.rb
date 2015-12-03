class AddNicknameToCollaborator < ActiveRecord::Migration
  def up
    add_column :collaborators, :nickname, :string
  end

  def down 
    remove_column :collaborators, :nickname
  end
end
