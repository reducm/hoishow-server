class Api::V1::ConcertsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    # TODO kaminari
    @concerts = Concert.limit(20)
  end

  def show
    @concert = Concert.find(params[:id])
  end
end
