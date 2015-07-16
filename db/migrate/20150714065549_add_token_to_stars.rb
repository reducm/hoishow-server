class AddTokenToStars < ActiveRecord::Migration
  def up 
    add_column :stars, :token, :string
  end
  
  def down 
    remove_column :stars, :token
  end
end
