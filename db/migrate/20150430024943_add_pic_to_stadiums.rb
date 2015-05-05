class AddPicToStadiums < ActiveRecord::Migration
  def change
    add_column :stadiums, :pic, :string
  end
end
