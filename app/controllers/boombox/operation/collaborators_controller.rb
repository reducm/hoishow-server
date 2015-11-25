class Boombox::Operation::CollaboratorsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    params[:per] ||= 10
    collaborators = Collaborator.all
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

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    # timeline
    params[:topics_page] ||= 1
    params[:topics_per] ||= 10
    boom_topics = @collaborator.boom_topics
    if params[:topics_q].present?
      @boom_topics = boom_topics.search(params[:topics_q]).page(params[:topics_page]).per(params[:topics_per]).records
    else
      @boom_topics = boom_topics.order(created_at: :desc).page(params[:topics_page]).per(params[:topics_per])
    end

    # tracks/playlists/shows/fans
    # tracks
    params[:tracks_page] ||= 1
    params[:tracks_per] ||= 10
    tracks = @collaborator.boom_tracks
    if params[:tracks_start_time].present?
      tracks = tracks.where("boom_tracks.created_at > '#{params[:tracks_start_time]}'")
    end

    if params[:tracks_end_time].present?
      tracks = tracks.where("boom_tracks.created_at < '#{params[:tracks_end_time]}'")
    end

    if params[:tracks_is_top].present?
      tracks = tracks.where(is_top: params[:tracks_is_top])
    end

    if params[:tracks_q].present?
      tracks = tracks.where("boom_tracks.name like '%#{params[:tracks_q]}%'")
    end

    @boom_tracks = tracks.page(params[:tracks_page]).order("boom_tracks.created_at desc").per(params[:tracks_per])

    #playlists
    params[:playlists_page] ||= 1
    params[:playlists_per] ||= 10
    playlists = @collaborator.boom_playlists

    if params[:playlists_start_time].present?
      playlists = playlists.where("boom_playlists.created_at > '#{params[:playlists_start_time]}'")
    end

    if params[:playlists_end_time].present?
      playlists = playlists.where("boom_playlists.created_at < '#{params[:playlists_end_time]}'")
    end

    if params[:playlists_is_top].present?
      playlists = playlists.where(is_top: params[:playlists_is_top])
    end

    if params[:playlists_q].present?
      playlists = playlists.where("boom_playlists.name like '%#{params[:playlists_q]}%'")
    end

    @boom_playlists = playlists.page(params[:playlists_page]).order("boom_playlists.created_at desc").per(params[:playlists_per])

    #activities
    params[:activities_page] ||= 1
    params[:activities_per] ||= 10
    activities = @collaborator.activities.activity

    if params[:activities_start_time].present?
      activities = activities.where("boom_activities.created_at > '#{params[:activities_start_time]}'")
    end

    if params[:activities_end_time].present?
      activities = activities.where("boom_activities.created_at < '#{params[:activities_end_time]}'")
    end

    if params[:activities_is_hot].present?
      activities = activities.where(is_hot: params[:activities_is_hot])
    end

    if params[:activities_q].present?
      activities = activities.where("boom_activities.name like '%#{params[:activities_q]}%'")
    end

    @activities = activities.page(params[:activities_page]).order("boom_activities.created_at desc").per(params[:activities_per])

    #users
    params[:users_page] ||= 1
    params[:users_per] ||= 10
    boom_users = @collaborator.followers

    if params[:users_q].present?
      boom_users = boom_users.where("users.nickname like '%#{params[:users_q]}%' or users.mobile like '%#{params[:users_q]}%'")
    end

    @users = boom_users.page(params[:users_page]).order("users.created_at desc").per(params[:users_per])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
  end

  def update
    if @collaborator.nickname != params[:collaborator][:nickname] && @collaborator.nickname_changeable?
      flash[:alert] = '昵称一个月只能修改一次'
      render action: 'edit'
    else
      if @collaborator.update(collaborator_params)
        redirect_to boombox_operation_collaborator_url(@collaborator), notice: '更新成功'
      else
        flash[:alert] = @collaborator.errors.full_messages.to_sentence
        render action: 'edit'
      end
    end
  end

  # 推荐／取消推荐
  def toggle_is_top
    if @collaborator.is_top?
      @collaborator.update_attributes(is_top: false)
      redirect_to boombox_operation_collaborators_url, notice: '取消推荐成功'
    else
      @collaborator.update_attributes(is_top: true)
      redirect_to boombox_operation_collaborators_url, notice: '推荐成功'
    end
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
