class Boombox::Dj::HomeController < Boombox::Dj::ApplicationController
  before_filter :check_login!

  def index
  end
end
