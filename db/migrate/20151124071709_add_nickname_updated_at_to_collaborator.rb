class AddNicknameUpdatedAtToCollaborator < ActiveRecord::Migration
  def change
    add_column :collaborators, :nickname_updated_at, :datetime, null: false
  end
end
