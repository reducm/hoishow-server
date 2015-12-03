class CreateBoomUserLikes < ActiveRecord::Migration
  def change
    create_table :boom_user_likes do |t|
      t.integer :user_id
      t.integer :subject_id
      t.string :subject_type

      t.timestamps null: false
    end
  end
end
