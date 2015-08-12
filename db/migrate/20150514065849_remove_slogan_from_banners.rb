class RemoveSloganFromBanners < ActiveRecord::Migration
  def up 
    remove_column :banners, :slogan
  end

  def down 
    add_column :banners, :slogan, :string
  end
end
