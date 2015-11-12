class AddUserIdAndStatusToBoomFeedbacks < ActiveRecord::Migration
  def up 
    add_column :boom_feedbacks, :user_id, :integer 
    add_column :boom_feedbacks, :status, :boolean
  end

  def down
    remove_column :boom_feedbacks, :user_id
    remove_column :boom_feedbacks, :status
  end
end
