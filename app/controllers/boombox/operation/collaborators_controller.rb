class Boombox::Operation::CollaboratorsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource only: [:index, :show, :new, :create, :edit, :update]

  def index
  end

  def show
    # timeline/tracks/playlists/shows/fans
  end

  def new
  end

  def create
    @collaborator = Collaborator.new(collaborator_params)
    if @collaborator.save
      redirect_to boombox_operation_collaborator_url(@collaborator), notice: '艺人新增成功。'
    else
      flash[:alert] = @collaborator.errors.full_messages.to_sentence
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @collaborator.update(collaborator_params)
      redirect_to boombox_operation_collaborator_url(@collaborator), notice: '艺人更新成功。'
    else
      flash[:alert] = @collaborator.errors.full_messages.to_sentence
      render action: 'edit'
    end
  end

  # 置顶
  def set_top 
  end

  private
  def collaborator_params
    params.require(:collaborator).permit(Collaborator.column_names.delete_if {|obj| obj.in? ["boom_id", "created_at", "updated_at"]}.map &:to_sym)
  end
end
