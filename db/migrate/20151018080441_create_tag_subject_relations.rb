class CreateTagSubjectRelations < ActiveRecord::Migration
  def change
    create_table :tag_subject_relations do |t|
      t.integer :boom_tag_id
      t.integer :subject_id
      t.string :subject_type

      t.timestamps null: false
    end
  end
end
