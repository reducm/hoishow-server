class ChangeSubjectToSubjectTypeForBanners < ActiveRecord::Migration
  def up
    rename_column :banners, :subject, :subject_type
  end

  def down
    rename_column :banners, :subject_type, :subject
  end
end
