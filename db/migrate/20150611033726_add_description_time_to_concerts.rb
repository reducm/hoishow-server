class AddDescriptionTimeToConcerts < ActiveRecord::Migration
  def up
    add_column :concerts, :description_time, :string
  end

  def down 
    remove_column :concerts, :description_time
  end
end
