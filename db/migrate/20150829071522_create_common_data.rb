class CreateCommonData < ActiveRecord::Migration
  def change
    create_table :common_data do |t|
      t.string :common_key
      t.string :common_value
      t.string :remark
      t.boolean :is_block, default: false

      t.timestamps null: false
    end
  end
end
