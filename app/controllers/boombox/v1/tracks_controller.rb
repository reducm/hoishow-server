class Boombox::V1::TracksController < Boombox::V1::ApplicationController
  def index
    if params[:keyword]
      @tracks = BoomboxSearch.query_search(params[:keyword])[:tracks]
      @tracks = Kaminari.paginate_array(@tracks).page(params[:page]).per(10)
    else
      @tracks = BoomTrack.recommend
    end
  end

  def show
    @track = BoomTrack.find_by_id params[:id]
  end
end
