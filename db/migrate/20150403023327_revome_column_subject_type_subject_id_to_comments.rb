class RevomeColumnSubjectTypeSubjectIdToComments < ActiveRecord::Migration
  def up
    remove_column :comments, :subject_type 
    remove_column :comments, :subject_id
  end

  def down
    add_column :comments, :subject_type 
    add_column :comments, :subject_id
  end
end
