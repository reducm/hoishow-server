class AddBikeUserIdAndChannelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bike_user_id, :integer
    add_column :users, :channel, :integer
    add_index :users, :bike_user_id
  end
end
