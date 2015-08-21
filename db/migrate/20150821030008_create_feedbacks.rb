class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :content
      t.string :mobile

      t.timestamps null: false
    end
  end
end
