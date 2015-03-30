class AddCityIdToUserVoteConcerts < ActiveRecord::Migration
  def up
    add_column :user_vote_concerts, :city_id, :integer
  end

  def down
    remove_column :user_vote_concerts, :city_id
  end
end
