class Operation::TopicsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def new
    @topic = Topic.new
    @concert = Concert.find_by_id(params[:concert_id])
    @stars = []
    if params[:star_id]
     @stars = Star.where(id: params[:star_id])
    elsif @concert
     @stars = @concert.stars
     @city_id = params[:city_id]
    end
  end

  def create
    @topic = Topic.new(require_attributes)
    Topic.transaction do
      if params[:creator] == current_admin.name
        @topic.creator_type = 'Admin'
        @topic.creator_id = current_admin.id
      else
        @topic.creator_type = 'Star'
        @topic.creator_id = params[:creator]
      end
      @topic.save!
    end
    redirect_to operation_root_path
  end

  def show
    @topic = Topic.find(params[:id])
  end

  private
  def require_attributes
    params.require(:topics).permit(:content, :subject_id, :subject_type, :city_id)
  end
end