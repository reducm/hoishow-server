class Api::V1::ConcertsController < Api::V1::ApplicationController
  before_action :check_has_user
#  def index
    ## TODO kaminari
    #@concerts = Concert.limit(20)
    #@shows = Show.limit(10)
  #end

  
    #TODO kaminari
  def get_all_object
    case params[:object_type]
    when "concert"
      @concerts = Concert.limit(20)
      render :partial => "api/v1/concerts/all_concerts", status: 200
    when "show"
      @shows = Show.limit(10)
      render :partial => "api/v1/shows/all_shows", status: 200
    else
      return error_json "the object_type is wrong"
    end
  end

end
