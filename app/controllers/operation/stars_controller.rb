# encoding: utf-8
class Operation::StarsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_star, only: [:new_show, :show, :edit, :update]
  before_action :get_videos, only: [:edit, :update]
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

  def create
    @star = Star.new(star_params)
    if @star.save
      redirect_to operation_star_url(@star), notice: '艺人新建成功。'
    else
      flash[:alert] = @star.errors.full_messages.to_sentence
      @star.delete
      render action: 'new'
    end
  end


  def edit
  end

  def update
    if @star.update(star_params)
      redirect_to operation_star_url(@star), notice: '艺人更新成功。'
    else
      flash[:alert] = @star.errors.full_messages.to_sentence
      render action: 'edit'
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
    params.require(:star).permit(:name, :is_display, :avatar, :poster, :position)
  end

  def get_star
    @star = Star.find(params[:id])
  end

  def get_videos
    @videos = @star.videos.order(is_main: :desc)
  end
end
