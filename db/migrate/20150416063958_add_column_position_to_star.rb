class AddColumnPositionToStar < ActiveRecord::Migration
  def change
    add_column :stars, :position, :integer
  end
end
