class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :description

      t.timestamps null: false
    end
  end
end
