class AddIndexToUsersMobile < ActiveRecord::Migration
  def change
    add_index :users, :mobile
  end
end
