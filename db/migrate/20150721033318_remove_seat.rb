class RemoveSeat < ActiveRecord::Migration
  # 不写成 up down 是因为，估计这个不需要 rollback
  def change
    drop_table :seats
  end
end
