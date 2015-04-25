class Operation::ShowsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @shows = Show.page(params[:page])
  end

end
