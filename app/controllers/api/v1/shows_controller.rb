class Api::V1::ShowsController < Api::V1::ApplicationController
  def index
    # TODO kaminari
    @shows = Show.limit(20)
  end
end
