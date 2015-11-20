class Boombox::Dj::PagesController < Boombox::Dj::ApplicationController
  skip_before_filter :check_login!
  
  def after_create_boom_admin 
    @boom_admin = BoomAdmin.find(params[:boom_admin_id]) 
  end

  def after_create_collaborator
    @collaborator = Collaborator.find(params[:collaborator_id])
  end
end
