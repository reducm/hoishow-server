class ChangeDefaultIsDisplay < ActiveRecord::Migration
  def change
    change_column_default :stars, :is_display, false
    change_column_default :shows, :is_display, false
    change_column_default :concerts, :is_show, 0
  end
end
