# encoding: utf-8
class Boombox::Operation::TracksController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_track, except: [:search, :index, :new, :create]

  def index
    params[:tracks_page] ||= 1
    params[:per] ||= 10
    tracks = BoomTrack.valid

    if params[:start_time].present?
      tracks = tracks.where("created_at > '#{params[:start_time]}'")
    end

    if params[:end_time].present?
      tracks = tracks.where("created_at < '#{params[:end_time]}'")
    end

    if params[:is_top].present?
      tracks = tracks.where(is_top: params[:is_top])
    end

    if params[:q].present?
      tracks = tracks.where("name like '%#{params[:q]}%'")
    end

    @tracks = tracks.page(params[:tracks_page]).order("created_at desc").per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def new
    @track = BoomTrack.new
  end

  def create
    @track = BoomTrack.new(track_params)
    @track.creator_id = @current_admin.id
    @track.creator_type = BoomTrack::CREATOR_ADMIN
    if @track.save!
      BoomTag.where('id in (?)', params[:tag_ids].split(',')).each{ |tag| @track.tag_for_track(tag) }
      flash[:notice] = '创建音乐成功'
      redirect_to boombox_operation_tracks_url
    end
  end

  def update
    if @track.update(track_params)
      #找出track的tag，跟params[:tag_ids]比较，没有的就删除,params[:tag_ids]格式为"1,2,3"
      target_tag_ids = params[:tag_ids]
      if target_tag_ids
        target_tag_ids = target_tag_ids.split(",").map{|target| target.to_i}
        source_tag_ids = @track.boom_tags.pluck(:id)
        #关联新tag，删除多余的tag
        new_tag_ids = target_tag_ids - source_tag_ids
        if new_tag_ids.present?
          BoomTag.where('id in (?)', new_tag_ids).each{ |tag| @track.tag_for_track(tag) }
        end
        del_tag_ids = source_tag_ids - target_tag_ids 
        if del_tag_ids.present?
          @track.tag_subject_relations.where('boom_tag_id in (?)', del_tag_ids).each{ |del_tag| del_tag.destroy! }
        end
      end
      flash[:notice] = '编辑音乐成功'
      redirect_to boombox_operation_tracks_url
    end
  end

  def edit
  end

  def destroy
    @track.destroy!
    redirect_to action: :index
  end

  def change_is_top
    if @track.is_top
      @track.update(is_top: false)
      flash[:notice] = "取消推荐成功"
    else
      @track.update(is_top: true)
      flash[:notice] = "更新推荐成功"
    end
    redirect_to boombox_operation_tracks_url
  end


  private
  def get_track
    @track = BoomTrack.find(params[:id])
  end

  def track_params
    params.require(:boom_track).permit(:cover, :name, :is_top, :file, :artists, :duration)
  end
end
