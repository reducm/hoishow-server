class AddSexToCollaborator < ActiveRecord::Migration
  def up
    add_column :collaborators, :sex, :integer
  end

  def down 
    remove_column :collaborators, :sex
  end
end
