class AddLinkUrlToMessages < ActiveRecord::Migration
  def up
    add_column :messages, :link_url, :string
  end
  def down
    remove_column :messages, :link_url
  end
end
