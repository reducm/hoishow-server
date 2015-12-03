class AddVerifiedToCollaborators < ActiveRecord::Migration
  def change
    add_column :collaborators, :verified, :boolean, default: false
  end
end
