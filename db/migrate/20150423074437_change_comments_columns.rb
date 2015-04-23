class ChangeCommentsColumns < ActiveRecord::Migration
  def change
    remove_column :comments, :user_id
    add_column :comments, :creator_id, :integer
    add_column :comments, :creator_type, :string
  end
end
