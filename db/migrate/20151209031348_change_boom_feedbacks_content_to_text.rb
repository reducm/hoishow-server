class ChangeBoomFeedbacksContentToText < ActiveRecord::Migration
  def change
    change_column :boom_feedbacks, :content, :text
  end
end
