class AddPosterToConcerts < ActiveRecord::Migration
  def up
    add_column :concerts, :poster, :string
  end

  def down
    remove_column :concerts, :poster
  end
end
