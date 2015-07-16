# encoding: utf-8
class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_star, only: [:new_show, :show, :edit, :update]
  before_action :get_videos, only: [:edit]
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    @stars = Star.all
  end

  def show
    @concerts = @star.concerts.page(params[:page])
    @shows = @star.shows.page(params[:page])
    @topics = @star.topics.page(params[:page])
    @users = @star.followers.page(params[:page])
  end

  def new
    @star = Star.new
    @star.token = @star.create_token
    @video = @star.videos.build
  end

  def create
    @star = Star.new(star_params)
    if @star.save
      videos = Video.where(star_token: @star.token, star_id: nil)
      if videos.any?
        videos.each do |video|
          video.update_attributes(star_id: @star.id)
        end
        videos.first.update(is_main: true)
        return redirect_to operation_star_url(@star), notice: '艺人新增成功。'
      end
      redirect_to operation_star_url(@star), notice: '艺人新增成功。'
    else
      @video = @star.videos.build
      flash[:alert] = @star.errors.full_messages.to_sentence
      render action: 'new'
    end
  end

  def edit
    @video = @star.videos.build
    @videos_uploaded_before = Video.star_id_not_set.where(star_token: @star.token)
  end

  def update
    if @star.update(star_params)
      videos = Video.where(star_token: @star.token, star_id: nil)
      if videos.any?
        videos.each do |video|
          video.update_attributes(star_id: @star.id)
        end
        unless @star.videos.is_main.count == 1
          videos.first.update(is_main: true)
        end
        return redirect_to operation_star_url(@star), notice: '艺人更新成功。'
      end
      redirect_to operation_star_url(@star), notice: '艺人更新成功。'
    else
      get_videos
      @video = @star.videos.build
      flash[:alert] = @star.errors.full_messages.to_sentence
      render action: 'edit'
    end
  end

  def new_show
    concert = Concert.create(name: @star.name + "(自动生成)", is_show: "auto_hide", status: "finished", start_date: Time.now, end_date: Time.now + 1)
    @star.hoi_concert(concert)
    begin
      redirect_to new_operation_show_url(concert_id: concert.id)
    rescue
      concert.delete
      flash[:alert] = "发布新演出失败"
      render action: 'show'
    end
  end

  def sort
    if params[:star].present?
      params[:star].each_with_index do |id, index|
        Star.where(id: id).update_all(position: index+1)
      end
    end
    render nothing: true
  end

  def get_topics
    @topics = @star.topics.page(params[:page])

    render partial: 'operation/topics/table', locals: {topics: @topics}
  end

  private
  def star_params
    params.require(:star).permit(:name, :is_display, :avatar, :poster, :position, :token)
  end

  def get_star
    @star = Star.find(params[:id])
  end

  def get_videos
    @videos = @star.videos.order(is_main: :desc)
  end
end
