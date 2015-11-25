class SetIsTopDefaultFalseToBoomTopics < ActiveRecord::Migration
  def change
    change_column :boom_topics, :is_top, :boolean, default: false
  end
end
