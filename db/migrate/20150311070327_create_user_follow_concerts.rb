class CreateUserFollowConcerts < ActiveRecord::Migration
  def change
    create_table :user_follow_concerts do |t|
      t.references :user, index: true
      t.references :concert, index: true

      t.timestamps null: false
    end
  end
end
