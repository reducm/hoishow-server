# encoding: utf-8
class Boombox::Dj::TracksController < Boombox::Dj::ApplicationController
  before_filter :check_login!
  before_filter :get_track, except: [:search, :index, :new, :create]

  def index
    @tracks = current_collaborator.boom_tracks 
    @tracks = @tracks.valid.page(params[:tracks_page]).order("created_at desc")
  end

  def search
    if params[:select_options] == "1"
      is_hot = true
    end
    if params[:q].present?
      @tracks = BoomTrack.valid.where("created_at > ? and created_at < ? and is_top = ?", params[:start_time], params[:end_time], is_hot).where("name like ?", "%#{params[:q]}%").page(params[:page]).order("created_at desc")
    elsif is_hot
      @tracks = BoomTrack.valid.where("created_at > ? and created_at < ? and is_top = ?", params[:start_time], params[:end_time], is_hot).page(params[:page]).order("created_at desc")
    else
      @tracks = BoomTrack.valid.where("created_at > ? and created_at < ?", params[:start_time], params[:end_time]).page(params[:page]).order("created_at desc")
    end
    render :index
  end

  def new
    @track = BoomTrack.new
  end

  def create
    @track = current_collaborator.boom_tracks.new(track_params)
    if @track.save!
      BoomTag.where('id in (?)', params[:tag_ids].split(',')).each{ |tag| @track.tag_for_track(tag) }
      flash[:notice] = '创建音乐成功'
      redirect_to boombox_dj_tracks_url(collaborator_id: current_collaborator.id)
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
      redirect_to boombox_dj_tracks_url(collaborator_id: current_collaborator.id)
    end
  end

  def edit
  end

  def destroy
    @track.destroy!
    redirect_to boombox_dj_tracks_url(collaborator_id: current_collaborator.id)
  end

  private
  def get_track
    @track = BoomTrack.find(params[:id])
  end

  def track_params
    params.require(:boom_track).permit(:cover, :name, :is_top, :file, :artists, :duration)
  end
end
