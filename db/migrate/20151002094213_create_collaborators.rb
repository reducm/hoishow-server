class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.string :boom_id
      t.string :boom_collaborator_type_id
      t.string :name
      t.string :email
      t.string :contact
      t.string :weibo
      t.string :cover
      t.string :wechat
      t.text :description
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :collaborators, :boom_id
  end
end
