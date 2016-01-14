# encoding: utf-8
class Boombox::Operation::BoomBannersController < Boombox::Operation::ApplicationController
  before_filter :get_boom_banner, except: [:index, :new, :create, :sort]

  def index
    @boom_banners = BoomBanner.page(params[:page])
  end

  def sort
    if params[:boom_banner].present?
      params[:boom_banner].each_with_index do |id, index|
        BoomBanner.where(id: id).update_all(position: index+1)
      end
    end
    render nothing: true
  end

  def new
    @boom_banner = BoomBanner.new
  end

  def create
    @boom_banner = BoomBanner.new(boom_banner_params)
    @boom_banner.subject_type = get_subject_type(params[:boom_banner][:subject_type])
    if @boom_banner.save
      flash[:notice] = "Banner创建成功"
      redirect_to boombox_operation_boom_banners_url
    else
      flash[:alert] = @boom_banner.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    @boom_banner.assign_attributes(boom_banner_params)
    @boom_banner.subject_type = get_subject_type(params[:boom_banner][:subject_type])
    if @boom_banner.save
      redirect_to boombox_operation_boom_banners_url
      flash[:notice] = "Banner更新成功"
    else
      flash[:alert] = @boom_banner.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @boom_banner.destroy
    redirect_to boombox_operation_boom_banners_url
  end

  private
  def get_boom_banner
    @boom_banner = BoomBanner.find(params[:id])
  end

  def boom_banner_params
    params.require(:boom_banner).permit(:subject_type, :subject_id, :poster)
  end

  def get_subject_type(type)
    case type
    when 'Playlist'
      'BoomPlaylist'
    when 'Show', 'Activity', 'News'
      'BoomActivity'
    else
      type
    end
  end
end
