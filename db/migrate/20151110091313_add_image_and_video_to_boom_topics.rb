class AddImageAndVideoToBoomTopics < ActiveRecord::Migration
  def change
    add_column :boom_topics, :image, :string
    add_column :boom_topics, :video_title, :string
    add_column :boom_topics, :video_url, :string
  end
end
