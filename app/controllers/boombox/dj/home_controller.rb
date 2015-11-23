class Boombox::Dj::HomeController < Boombox::Dj::ApplicationController
  before_filter :check_login!

  def index
    @collaborator = Collaborator.where(boom_admin_id: current_admin.id).first
  end
end
