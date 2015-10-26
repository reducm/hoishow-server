class Boombox::V1::ActivitiesController < Boombox::V1::ApplicationController
  before_action :get_user

  def index
    @activities = BoomActivity.is_display.page(params[:page])
  end

  def show
    @activity = BoomActivity.find_by_id params[:id]
  end
end
