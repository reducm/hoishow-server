class Api::V1::StarsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    @stars = Star.limit(18)
  end

  def show
    @star = Star.find(params[:id])
  end
end
