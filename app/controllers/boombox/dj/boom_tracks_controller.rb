# encoding: utf-8
class Boombox::Dj::BoomTracksController < Boombox::Dj::ApplicationController
  before_filter :check_login!
  before_filter :get_track, except: [:search, :index, :new, :create]

  def index
    @tracks = current_collaborator.boom_tracks 
    @tracks = @tracks.valid.page(params[:tracks_page]).order("created_at desc")
  end

  def search
    tracks = current_collaborator.boom_tracks.valid
    if params[:q].present?
      tracks = tracks.where("name like ?", "%#{params[:q]}%")
    end
    tracks = tracks.where("created_at > ? and created_at < ?", params[:start_time], params[:end_time])
    @tracks = tracks.order("created_at desc").page(params[:page])
    render :index
  end

  def new
    @track = current_collaborator.boom_tracks.new
  end

  def create
    @track = current_collaborator.boom_tracks.new(track_params)
    if @track.save
      BoomTag.where('id in (?)', params[:tag_ids].split(',')).each{ |tag| @track.tag_for_track(tag) }
      flash[:notice] = '创建音乐成功'
      redirect_to boombox_dj_boom_tracks_url
    else
      flash[:alert] = @track.errors.full_messages 
      @track = current_collaborator.boom_tracks.new
      render :new
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
      redirect_to boombox_dj_boom_tracks_url
    end
  end

  def edit
  end

  def destroy
    @track.destroy!
    redirect_to boombox_dj_boom_tracks_url
  end

  private
  def get_track
    @track = BoomTrack.find(params[:id])
  end

  def track_params
    params.require(:boom_track).permit(:cover, :name, :is_top, :file, :artists, :duration)
  end
end
