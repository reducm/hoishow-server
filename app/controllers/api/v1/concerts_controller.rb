class Api::V1::ConcertsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    @concerts = Concert.limit(25)
  end


end
