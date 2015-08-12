class AddRefundByToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :refund_by, :string
  end
end
