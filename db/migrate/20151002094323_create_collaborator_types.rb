class CreateCollaboratorTypes < ActiveRecord::Migration
  def change
    create_table :collaborator_types do |t|
      t.string :boom_id
      t.string :code
      t.string :name
      t.integer :value
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :collaborator_types, :boom_id
  end
end
