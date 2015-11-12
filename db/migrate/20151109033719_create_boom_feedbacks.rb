class CreateBoomFeedbacks < ActiveRecord::Migration
  def change
    create_table :boom_feedbacks do |t|
      t.string :content
      t.string :contact

      t.timestamps null: false
    end
  end
end
