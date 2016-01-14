class Boombox::V1::ActivitiesController < Boombox::V1::ApplicationController
  before_action :get_user
  skip_before_filter :api_verify!, only: [:description]

  def index
    if params[:keyword]
      @activities = BoomActivity.search(params[:keyword]).records.where.not(mode: 2).is_display.to_a
      @activities = Kaminari.paginate_array(@activities).page(params[:page]).per(10)
    else
      @activities = BoomActivity.is_display.page(params[:page])
    end
  end

  def show
    @activity = BoomActivity.find_by_id params[:id]
  end

  def description
    @activity = BoomActivity.find_by_id params[:id]

    render layout: 'boombox_mobile'
  end
end
