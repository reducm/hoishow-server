class AddBirthToCollaborator < ActiveRecord::Migration
  def up
    add_column :collaborators, :birth, :datetime
  end

  def down 
    remove_column :collaborators, :birth
  end
end
