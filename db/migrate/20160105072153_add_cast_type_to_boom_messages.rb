class AddCastTypeToBoomMessages < ActiveRecord::Migration
  def change
    add_column :boom_messages, :cast_type, :integer
  end
end
