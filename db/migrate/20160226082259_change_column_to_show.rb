class ChangeColumnToShow < ActiveRecord::Migration
  def change
    change_column :shows, :description, :text, limit: 16777215
  end
end
