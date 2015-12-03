class CreateUserFollowCollaborators < ActiveRecord::Migration
  def change
    create_table :user_follow_collaborators do |t|
      t.integer :user_id
      t.integer :collaborator_id

      t.timestamps null: false
    end

    add_index :user_follow_collaborators, :user_id
    add_index :user_follow_collaborators, :collaborator_id
  end
end
