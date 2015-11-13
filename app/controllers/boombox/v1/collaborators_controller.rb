class Boombox::V1::CollaboratorsController < Boombox::V1::ApplicationController
  before_action :get_user
  before_action :get_collaborator, except: [:index]

  def index
    if params[:keyword]
      @collaborators = BoomboxSearch.query_search(params[:keyword])[:collaborators]
      @collaborators = Kaminari.paginate_array(@collaborators).page(params[:page]).per(10)
    else
      @collaborators = Collaborator.verified.page(params[:page])
    end
  end

  def show
  end

  def timeline
    @topics = @collaborator.boom_topics.page(params[:page])
  end

  def comments
    @topic = @collaborator.boom_topics.where(id: params[:topic_id]).first
    if @topic
      @comments = @topic.boom_comments.page(params[:page])
    else
      error_respond('topic not found')
    end
  end

  def playlists
    @playlists = @collaborator.boom_playlists.playlist.page(params[:page])
  end

  def tracks
    @tracks = @collaborator.boom_tracks.page(params[:page])
  end

  def shows
    @shows = @collaborator.activities.page(params[:page])
  end

  private
  def get_collaborator
    @collaborator = Collaborator.find_by_id params[:id]
  end
end
