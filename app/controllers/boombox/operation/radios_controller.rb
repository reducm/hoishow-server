# encoding: utf-8
class Boombox::Operation::RadiosController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_radio, except: [:search, :index, :new, :create]

  def index
    @radios = BoomPlaylist.valid_radios.page(params[:page]).order("created_at desc")
  end

  def search
    if params[:select_options] == "1"
      is_hot = true
    end
    if params[:q].present?
      @radios = BoomPlaylist.valid_radios.where("created_at > ? and created_at < ? and is_top = ?", params[:start_time], params[:end_time], is_hot).where("name like ?", "%#{params[:q]}%").page(params[:page]).order("created_at desc")
    elsif is_hot
      @radios = BoomPlaylist.valid_radios.where("created_at > ? and created_at < ? and is_top = ?", params[:start_time], params[:end_time], is_hot).page(params[:page]).order("created_at desc")
    else
      @radios = BoomPlaylist.valid_radios.where("created_at > ? and created_at < ?", params[:start_time], params[:end_time]).page(params[:page]).order("created_at desc")
    end
    render :index
  end

  def new
    @radio = BoomPlaylist.new
  end

  def create
    @radio = BoomPlaylist.new(radio_params)
    @radio.creator_id = @current_admin.id
    @radio.creator_type = BoomTrack::CREATOR_ADMIN
    @radio.mode = 1
    if @radio.save!
      BoomTag.where('id in (?)', params[:tag_ids].split(',')).each{ |tag| @radio.tag_for_playlist(tag) }
      flash[:notice] = '创建电台成功'
      redirect_to boombox_operation_radios_url
    end
  end

  def update
    if @radio.update(radio_params)
      target_tag_ids = params[:tag_ids]
      if target_tag_ids
        target_tag_ids = target_tag_ids.split(",").map{|target| target.to_i}
        source_tag_ids = @radio.boom_tags.pluck(:id)
        #关联新tag，删除多余的tag
        new_tag_ids = target_tag_ids - source_tag_ids
        if new_tag_ids.present?
          BoomTag.where('id in (?)', new_tag_ids).each{ |tag| @radio.tag_for_playlist(tag) }
        end
        del_tag_ids = source_tag_ids - target_tag_ids 
        if del_tag_ids.present?
          @radio.tag_subject_relations.where('boom_tag_id in (?)', del_tag_ids).each{ |del_tag| del_tag.destroy! }
        end
      end
      flash[:notice] = '编辑电台成功'
      redirect_to boombox_operation_radios_url
    end
  end

  def edit
  end

  def destroy
    @radio.destroy!
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


  private
  def get_radio
    @radio = BoomPlaylist.find(params[:id])
  end

  def radio_params
    params.require(:boom_playlist).permit(:cover, :name, :is_top)
  end
end
