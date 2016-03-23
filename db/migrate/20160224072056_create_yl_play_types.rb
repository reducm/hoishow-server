class CreateYlPlayTypes < ActiveRecord::Migration
  def change
    create_table :yl_play_types do |t|
      t.integer :play_type_a_id
      t.string :play_type_a
      t.integer :play_type_b_id
      t.string :play_type_b

      t.timestamps null: false
    end
  end
end
