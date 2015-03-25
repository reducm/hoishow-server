class CreateUserVoteConcerts < ActiveRecord::Migration
  def change
    create_table :user_vote_concerts do |t|
      t.integer :user_id
      t.integer :concert_id

      t.timestamps null: false
    end
  end
end
