class Boombox::V1::TracksController < Boombox::V1::ApplicationController
  def recommend
    @tracks = BoomTrack.recommend
  end

  def show
    @track = BoomTrack.find_by_id params[:id]
  end
end
