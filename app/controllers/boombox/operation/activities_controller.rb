# encoding: utf-8
class Boombox::Operation::ActivitiesController < Boombox::Operation::ApplicationController
  before_filter :get_activity, except: [:search, :index, :new, :create, :upload_image]

  def index
    params[:activities_page] ||= 1
    params[:activities_per] ||= 10
    activities = BoomActivity.activity

    if params[:activities_start_time].present?
      activities = activities.where("created_at > '#{params[:activities_start_time]}'")
    end

    if params[:activities_end_time].present?
      activities = activities.where("created_at < '#{params[:activities_end_time]}'")
    end

    if params[:activities_is_hot].present?
      activities = activities.where(is_hot: params[:activities_is_hot])
    end

    if params[:activities_q].present?
      activities = activities.where("name like ?", "%#{params[:activities_q]}%")
    end

    @activities = activities.page(params[:activities_page]).order("created_at desc").per(params[:activities_per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def new
    @activity = BoomActivity.new
    @tags = get_all_tag_names
    @activity_collaborators = Collaborator.verified.pluck(:nickname)
  end

  def create
    @activity = BoomActivity.new(activity_params)
    @activity.mode = "activity"

    if @activity.save
      if params[:boom_activity][:activity_tag_names].present?
        subject_relate_tag(params[:boom_activity][:activity_tag_names], @activity)
      end

      if params[:boom_activity][:activity_collaborator_nicknames].present?
        collaborator_nicknames_array = params[:boom_activity][:activity_collaborator_nicknames].split(",")
        collaborators = Collaborator.where(nickname: collaborator_nicknames_array)
        collaborator_ids = collaborators.pluck(:id)
        collaborators.each do |c|
          c.collaborator_activity_relations.where(boom_activity_id: @activity.id).first_or_create!
        end
        @activity.collaborator_activity_relations.where.not(collaborator_id: collaborator_ids).delete_all
      end

      flash[:notice] = '创建活动成功'
    else
      flash[:alert] = '创建活动失败'
    end

    redirect_to boombox_operation_activities_url
  end

  def update
    if @activity.update(activity_params)
      if params[:boom_activity][:activity_tag_names].present?
        subject_relate_tag(params[:boom_activity][:activity_tag_names], @activity)
      end

      if params[:boom_activity][:activity_collaborator_nicknames].present?
        collaborator_nicknames_array = params[:boom_activity][:activity_collaborator_nicknames].split(",")
        collaborators = Collaborator.where(nickname: collaborator_nicknames_array)
        collaborator_ids = collaborators.pluck(:id)
        collaborators.each do |c|
          c.collaborator_activity_relations.where(boom_activity_id: @activity.id).first_or_create!
        end
        @activity.collaborator_activity_relations.where.not(collaborator_id: collaborator_ids).delete_all
      end
      flash[:notice] = '编辑活动成功'
    else
      flash[:alert] = '编辑活动失败'
    end

    redirect_to boombox_operation_activities_url
  end

  def edit
    @tags = get_all_tag_names
    @activity_collaborators = Collaborator.verified.pluck(:nickname)
  end

  def change_is_top
    #只有一个置顶，update all(is_top)
    if @activity.is_top
      @activity.update(is_top: false)
    else
      BoomActivity.activity.update_all(is_top: false)
      @activity.update(is_top: true)
    end
    redirect_to boombox_operation_activities_url
  end

  def upload_cover
    @activity.update(activity_params)

    render json: {success: true, cover_path: @activity.cover_url}
  end

  def upload_image
    image = SimditorImage.create(image: params[:file])
    render json: {file_path: image.image_url}
  end

  private
  def get_activity
    @activity = BoomActivity.find(params[:id])
  end

  def activity_params
    params.require(:boom_activity).permit(:cover, :name, :is_hot, :is_display, :description)
  end
end
