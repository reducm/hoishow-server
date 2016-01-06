# encoding: utf-8
class Boombox::Operation::RadiosController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_radio, except: [:search, :index, :new, :create]

  def index
    params[:page] ||= 1
    params[:per] ||= 10
    radios = BoomPlaylist.valid_radios

    if params[:start_time].present?
      radios = radios.where("created_at > '#{params[:start_time]}'")
    end

    if params[:end_time].present?
      radios = radios.where("created_at < '#{params[:end_time]}'")
    end

    if params[:is_top].present?
      radios = radios.where(is_top: params[:is_top])
    end

    if params[:q].present?
      radios = radios.where("name like ?", "%#{params[:q]}%")
    end

    @radios = radios.page(params[:page]).order("created_at desc").per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end

  end

  def new
    @radio = BoomPlaylist.new
    @tags = get_all_tag_names
  end

  def create
    @radio = BoomPlaylist.new(radio_params)
    @radio.creator_id = @current_admin.id
    @radio.creator_type = BoomTrack::CREATOR_ADMIN
    @radio.mode = 1

    if @radio.save
      if params[:boom_playlist][:playlist_tag_names].present?
        subject_relate_tag(params[:boom_playlist][:playlist_tag_names], @radio)
      end
      flash[:notice] = '创建电台成功'
    else
      flash[:alert] = '创建电台失败'
    end

    redirect_to boombox_operation_radios_url
  end

  def update
    if @radio.update(radio_params)
      if params[:boom_playlist][:playlist_tag_names].present?
        subject_relate_tag(params[:boom_playlist][:playlist_tag_names], @radio)
      end
      flash[:notice] = '编辑电台成功'
    else
      flash[:alert] = '编辑电台失败'
    end

    redirect_to boombox_operation_radios_url
  end

  def edit
    @tags = get_all_tag_names
  end

  def destroy
    if @radio.destroy
      flash[:notice] = "删除电台成功"
    else
      flash[:alert] = "删除电台失败"
    end
    redirect_to action: :index
  end

  def change_is_top
    if @radio.is_top
      @radio.update(is_top: false)
      flash[:notice] = "取消推荐成功"
    else
      @radio.update(is_top: true)
      flash[:notice] = "更新推荐成功"
    end
    redirect_to boombox_operation_radios_url
  end

  def manage_tracks
    radio_tracks = @radio.tracks.where(removed: false)
    radio_track_ids = radio_tracks.pluck(:id)
    @radio_tracks = radio_tracks.page(params[:playlist_tracks_page]).order('is_top desc, created_at desc')
    total_tracks = BoomTrack.valid
    if radio_track_ids.present?
      total_tracks = total_tracks.where("id not in (?)", radio_track_ids)
    end
    @tracks =
      if params[:q].present?
        total_tracks.where("name like '%#{params[:q]}%'").page(params[:search_tracks_page])
      else
        total_tracks.page(params[:search_tracks_page])
      end
  end

  def add_track
    @radio.playlist_track_relations.where(boom_track_id: params[:track_id]).first_or_create
    render json: { success: true }
  end

  def remove_track
    relation = @radio.playlist_track_relations.where(boom_track_id: params[:track_id]).first
    if relation
      if relation.destroy
        render json: { success: true }
      else
        render json: { success: false }
      end
    end
  end

  def publish
    if @radio.update(is_display: 1)
      flash[:notice] = '电台发布成功'
    else
      flash[:error] = '电台发布失败'
    end

    redirect_to manage_tracks_boombox_operation_radio_url(@radio)
  end

  private
  def get_radio
    @radio = BoomPlaylist.find(params[:id])
  end

  def radio_params
    params.require(:boom_playlist).permit(:cover, :name, :is_top)
  end
end
