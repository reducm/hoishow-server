# encoding: utf-8
class Boombox::Operation::RadiosController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_radio, except: [:search, :index, :new, :create]

  def index
    params[:activities_page] ||= 1
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
      radios = radios.where("name like '%#{params[:q]}%'")
    end

    @radios = radios.page(params[:page]).order("created_at desc").per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end

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
