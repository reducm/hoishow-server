class AddSourceAndSourceIdToStadiums < ActiveRecord::Migration
  def change
    add_column :stadiums, :source, :integer
    add_column :stadiums, :source_id, :integer
  end
end
