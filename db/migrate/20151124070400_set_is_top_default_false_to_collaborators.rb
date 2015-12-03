class SetIsTopDefaultFalseToCollaborators < ActiveRecord::Migration
  def change
    change_column :collaborators, :is_top, :boolean, default: false
  end
end
