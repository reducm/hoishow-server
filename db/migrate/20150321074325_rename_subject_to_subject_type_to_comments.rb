class RenameSubjectToSubjectTypeToComments < ActiveRecord::Migration
  def up
    rename_column :comments, :subject, :subject_type
  end

  def down
    rename_column :comments, :subject_type, :subject
  end
end
