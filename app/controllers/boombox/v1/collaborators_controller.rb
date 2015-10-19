class Boombox::V1::CollaboratorsController < Boombox::V1::ApplicationController
  before_action :get_user
  before_action :check_login!, only: [:comments]
  before_action :get_collaborator, except: [:index]

  def index
    @collaborators = Collaborator.verified.page(params[:page])
  end

  def show
  end

  def timeline
    @topics = @collaborator.boom_topics
  end

  def comments
    topic = @collaborator.boom_topics.where(id: params[:topic_id]).first
    if topic
      @comments = topic.boom_comments
    else
      error_respond('topic not found')
    end
  end

  def playlists
    @playlists = @collaborator.boom_playlists.playlist
  end

  def tracks
    @tracks = @collaborator.boom_tracks
  end

  def shows
    @shows = @collaborator.activities
  end

  private
  def get_collaborator
    @collaborator = Collaborator.find_by_id params[:id]
  end
end
