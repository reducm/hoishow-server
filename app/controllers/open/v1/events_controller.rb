# encoding: utf-8
class Open::V1::EventsController < Open::V1::ApplicationController
  before_action :show_auth!
  def index
    @events = @show.events.all
  end
end
