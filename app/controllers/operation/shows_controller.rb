class Operation::ShowsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    if params[:q].present?
      @stars = Star.search(params[:q])
      @shows = @stars.map{|star| star.shows}.flatten.page(params[:page])

    else
      @shows = Show.page(params[:page])
    end
  end

end
