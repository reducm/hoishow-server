class AddMultipleColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :source_id, :integer
    add_column :orders, :area_source_id, :integer
    add_column :orders, :unit_price, :decimal, precision: 10, scale: 2
    add_column :orders, :express_name, :string
    add_column :orders, :id_card, :string
  end
end
