class CreateUserFollowShows < ActiveRecord::Migration
  def change
    create_table :user_follow_shows do |t|
      t.references :user, index: true
      t.references :show, index: true

      t.timestamps null: false
    end
  end
end
