class AddExpireTimeToBoomMessages < ActiveRecord::Migration
  def change
    add_column :boom_messages, :expire_time, :datetime
  end
end
