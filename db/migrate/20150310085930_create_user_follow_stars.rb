class CreateUserFollowStars < ActiveRecord::Migration
  def change
    create_table :user_follow_stars do |t|
      t.references :user, index: true
      t.references :star, index: true

      t.timestamps null: false
    end
  end
end
