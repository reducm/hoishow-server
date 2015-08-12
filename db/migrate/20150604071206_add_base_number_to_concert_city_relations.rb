class AddBaseNumberToConcertCityRelations < ActiveRecord::Migration
  def up
    add_column :concert_city_relations, :base_number, :integer, default:0
  end
  def down
    remove_column :concert_city_relations, :base_number
  end
end
