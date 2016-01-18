class Boombox::Operation::NewsController < Boombox::Operation::ApplicationController
  before_action :get_news, only: [:edit, :update, :toggle_is_top]

  def index
    params[:news_page] ||= 1
    params[:news_per] ||= 10
    newses = BoomActivity.news

    if params[:news_start_time].present?
      newses = newses.where("created_at > '#{params[:news_start_time]}'")
    end

    if params[:news_end_time].present?
      newses = newses.where("created_at < '#{params[:news_end_time]}'")
    end

    if params[:news_q].present?
      newses = newses.where("name like ?", "%#{params[:news_q]}%")
    end

    @newses = newses.page(params[:news_page]).order("created_at desc").per(params[:news_per])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @news = BoomActivity.new
  end

  def create
    @news = BoomActivity.new(news_params)
    if @news.save
      flash[:notice] = '创建资讯成功'
    else
      flash[:notice] = '创建资讯失败'
    end

    redirect_to boombox_operation_news_index_url
  end

  def edit
  end

  def update
    @news.assign_attributes(news_params)
    if @news.save
      flash[:notice] = '更新资讯成功'
    else
      flash[:notice] = '更新资讯失败'
    end

    redirect_to boombox_operation_news_index_url
  end

  def toggle_is_top
    #只有一个置顶，update all(is_top)
    if @news.is_top
      @news.update(is_top: 0)
    else
      BoomActivity.news.update_all(is_top: 0)
      @news.update(is_top: 1)
    end
    redirect_to boombox_operation_news_index_url
  end

  private
  def news_params
    params.require(:boom_activity).permit(:name, :cover, :is_display, :description, :mode)
  end

  def get_news
    @news = BoomActivity.find params[:id]
  end
end
