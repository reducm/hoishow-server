class AddSourceNameToStadiums < ActiveRecord::Migration
  def change
    add_column :stadiums, :source_name, :string
  end
end
