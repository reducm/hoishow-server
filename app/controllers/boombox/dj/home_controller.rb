class Boombox::Dj::HomeController < Boombox::Dj::ApplicationController
  before_filter :check_login!

  def index
    @collaborator = Collaborator.find(current_admin.id)
  end
end
