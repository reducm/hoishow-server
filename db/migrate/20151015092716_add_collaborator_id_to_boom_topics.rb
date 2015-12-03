class AddCollaboratorIdToBoomTopics < ActiveRecord::Migration
  def change
    add_column :boom_topics, :collaborator_id, :integer
  end
end
