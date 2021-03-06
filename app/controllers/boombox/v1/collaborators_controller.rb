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
    @topics = if params[:last]
                @collaborator.boom_topics.where('boom_topics.id < ?', params[:last]).first(10)
              else
                @collaborator.boom_topics.first(10)
              end
  end

  def comments
    @topic = @collaborator.boom_topics.where(id: params[:topic_id]).first
    if @topic
      @comments = if params[:last]
                    @topic.boom_comments.where('boom_comments.id < ?', params[:last]).first(10)
                  else
                    @topic.boom_comments.first(10)
                  end
    else
      error_respond('topic not found')
    end
  end

  def playlists
    @playlists = @collaborator.boom_playlists.playlist.order('created_at desc').page(params[:page])
  end

  def tracks
    @tracks = if params[:is_all]
                @collaborator.boom_tracks.order('created_at desc')
              else
                @collaborator.boom_tracks.order('created_at desc').page(params[:page])
              end
  end

  def shows
    @shows = @collaborator.activities.order('collaborator_activity_relations.created_at desc').page(params[:page])
  end

  private
  def get_collaborator
    @collaborator = Collaborator.find_by_id params[:id]
  end
end
