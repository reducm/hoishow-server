class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :area, index: true
      t.references :show, index: true
      t.decimal :price
      t.references :order, index: true
      t.string :code
      t.datetime :code_valid_time

      t.timestamps null: false
    end
  end
end
