class Boombox::V1::CollaboratorsController < Boombox::V1::ApplicationController
  before_filter :get_user

  def index
    @collaborators = Collaborator.verified.page(params[:page])
  end

  def show
    @collaborator = Collaborator.find params[:id]
  end
end
