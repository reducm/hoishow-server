# encoding: utf-8
class Boombox::Operation::ActivitiesController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_activity, except: [:search, :index, :new, :create, :get_video_url]

  def index
    params[:activities_page] ||= 1
    params[:per] ||= 10
    activities = BoomActivity.all

    if params[:start_time].present?
      activities = activities.where("created_at > '#{params[:start_time]}'")
    end

    if params[:end_time].present?
      activities = activities.where("created_at < '#{params[:end_time]}'")
    end

    if params[:is_hot].present?
      activities = activities.where(is_hot: params[:is_hot])
    end

    if params[:q].present?
      activities = activities.where("name like '%#{params[:q]}%'")
    end

    @activities = activities.page(params[:activities_page]).order("created_at desc").per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def new
    @activity = BoomActivity.new
  end

  def create
    @activity = BoomActivity.new(activity_params)
    if @activity.save!
      #关联tag
      BoomTag.where('id in (?)', params[:tag_ids].split(',')).each{ |tag| @activity.tag_for_activity(tag) }
      #关联艺人
      Collaborator.where('id in (?)', params[:collaborator_ids].split(',')).each{ |collaborator| @activity.relate_collaborator(collaborator) }

      flash[:notice] = '创建活动成功'
      redirect_to boombox_operation_activities_url
    end
  end

  def update
    if @activity.update(activity_params)
      #关联新tag，删除多余的tag
      target_tag_ids = params[:tag_ids]
      if target_tag_ids
        target_tag_ids = target_tag_ids.split(",").map{|target| target.to_i}
        source_tag_ids = @activity.boom_tags.pluck(:id)
        new_tag_ids = target_tag_ids - source_tag_ids
        if new_tag_ids.present?
          BoomTag.where('id in (?)', new_tag_ids).each{ |tag| @activity.tag_for_activity(tag) }
        end
        del_tag_ids = source_tag_ids - target_tag_ids
        if del_tag_ids.present?
          @activity.tag_subject_relations.where('boom_tag_id in (?)', del_tag_ids).each{ |del_tag| del_tag.destroy! }
        end
      end

      #关联新collaborator，删除多余的collaborator
      target_collaborator_ids = params[:collaborator_ids]
      if target_collaborator_ids
        target_collaborator_ids = target_collaborator_ids.split(",").map{|target| target.to_i}
        source_collaborator_ids = @activity.collaborators.pluck(:id)
        new_collaborator_ids = target_collaborator_ids - source_collaborator_ids
        if new_collaborator_ids.present?
          Collaborator.where('id in (?)', new_collaborator_ids).each{ |collaborator| @activity.relate_collaborator(collaborator) }
        end
        del_collaborator_ids = source_collaborator_ids - target_collaborator_ids
        if del_collaborator_ids.present?
          @activity.collaborator_activity_relations.where('collaborator_id in (?)', del_collaborator_ids).each{ |del_collaborator| del_collaborator.destroy! }
        end
      end

      flash[:notice] = '编辑活动成功'
      redirect_to boombox_operation_activities_url
    end
  end

  def edit
  end

  def change_is_top
    #只有一个置顶，update all(is_top)
    if @activity.is_top
      @activity.update(is_top: false)
    else
      BoomActivity.update_all(is_top: false)
      @activity.update(is_top: true)
    end
    redirect_to boombox_operation_activities_url
  end

  def upload_cover
    @activity.update(activity_params)

    render json: {success: true, cover_path: @activity.cover_url}
  end

  private
  def get_activity
    @activity = BoomActivity.find(params[:id])
  end

  def activity_params
    params.require(:boom_activity).permit(:cover, :name, :is_hot, :is_display, :description)
  end
end
