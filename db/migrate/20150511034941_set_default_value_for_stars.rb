class SetDefaultValueForStars < ActiveRecord::Migration
  def up
    change_column :stars, :is_display, :boolean, :default => true 
  end
end
