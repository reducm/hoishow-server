class AddDistrictIdToStadiums < ActiveRecord::Migration
  def up 
    add_column :stadiums, :district_id, :integer
  end

  def down
    remove_column :stadiums, :district_id
  end


end
