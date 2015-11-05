class Boombox::Operation::CollaboratorsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    params[:per] ||= 10
    collaborators = Collaborator.all
    # 列表显示艺人总数
    @collaborators_count = collaborators.count
    # 按推荐过滤
    if params[:is_top].present?
      collaborators = collaborators.where(is_top: params[:is_top])
    end
    # 按关键词过滤
    if params[:q].present?
      collaborators = collaborators.where("collaborators.name like :search", search: "%#{params[:q]}%")
    end
    # 分页，每页显示数量
    @collaborators = collaborators.order(created_at: :desc).page(params[:page]).per(params[:per])
    # 将参数回传 
    @is_top = params[:is_top]
    @per = params[:per]
  end

  def show
    @boom_albums = BoomAlbum.where(collaborator_id: params[:id])
    # timeline/tracks/playlists/shows/fans
  end

  def edit
  end

  def update
    if nickname_changeable?(@collaborator, params[:collaborator][:nickname])
      if @collaborator.update(collaborator_params)
        redirect_to boombox_operation_collaborator_url(@collaborator), notice: '艺人更新成功。'
      else
        flash[:alert] = @collaborator.errors.full_messages.to_sentence
        render action: 'edit'
      end
    else
      flash[:alert] = '昵称一个月只能改一次' 
      render action: 'edit'
    end
  end

  # 推荐 
  def set_top 
    @collaborator.update_attributes(is_top: true)
    redirect_to boombox_operation_collaborators_url, notice: '推荐成功'
  end

  # 通过审核
  def verify 
    if @collaborator.update_attributes(verified: true)
      redirect_to boombox_operation_collaborator_url(@collaborator), notice: '通过审核成功'
    else
      flash[:alert] = @collaborator.errors.full_messages.to_sentence
      render :edit
    end
  end

  private
  def collaborator_params
    params.require(:collaborator).permit(Collaborator.column_names.delete_if {|obj| obj.in? ["boom_id", "created_at", "updated_at", "name"]}.map &:to_sym)
  end
end
