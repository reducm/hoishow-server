class ChangeMinPirceToMinPriceForShows < ActiveRecord::Migration
  def up
    rename_column :shows, :min_pirce, :min_price
  end

  def down
    rename_column :shows, :min_price, :min_pirce
  end
end
