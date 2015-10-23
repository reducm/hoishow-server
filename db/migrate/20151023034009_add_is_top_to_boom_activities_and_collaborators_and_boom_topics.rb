class AddIsTopToBoomActivitiesAndCollaboratorsAndBoomTopics < ActiveRecord::Migration
  def change
    tables = [:boom_activities, :collaborators, :boom_topics]

    tables.each do |table_name|
      add_column table_name, :is_top, :boolean
    end
  end
end
