class CreateCollaboratorActivityRelations < ActiveRecord::Migration
  def change
    create_table :collaborator_activity_relations do |t|
      t.references :collaborator, index: true
      t.references :boom_activity, index: true

      t.timestamps null: false
    end
  end
end
