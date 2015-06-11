class PagesController < ApplicationController
  layout false

  def index
  end

  def about
  end

  def wap_index
  end

  def wap_about
  end

  def sharing_show
    @show = Show.find_by_id(params[:show_id])

    render layout: 'mobile'
  end
end
