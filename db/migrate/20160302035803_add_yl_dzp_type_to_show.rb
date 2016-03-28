class AddYlDzpTypeToShow < ActiveRecord::Migration
  def change
    add_column :shows, :yl_dzp_type, :integer
  end
end
