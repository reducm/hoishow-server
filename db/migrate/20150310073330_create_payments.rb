class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :purchase_id
      t.string :purchase_type
      t.string :payment_type
      t.integer :status
      t.string :trade_id
      t.datetime :pay_at
      t.datetime :refund_at
      t.decimal :amount
      t.decimal :refund_amount
      t.string :paid_origin
      t.references :order, index: true

      t.timestamps null: false
    end
    add_foreign_key :payments, :orders
  end
end
