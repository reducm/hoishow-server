class Operation::StaticPagesController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_page, only: [:edit, :update, :description]

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    if @page.save
      flash[:notice] = '静态页创建成功'
      redirect_to operation_static_pages_url
    else
      flash[:error] = '静态页创建失败'
      render :new
    end
  end

  def edit
  end

  def update
    if @page.update(page_params)
      flash[:notice] = '静态页修改成功'
      redirect_to operation_static_pages_url
    else
      flash[:error] = '静态页修改失败'
      render :edit
    end
  end

  def description
    render layout: 'mobile'
  end

  private
  def get_page
    @page = Page.find params[:id]
  end

  def page_params
    params.require(:page).permit(:title, :description)
  end
end
