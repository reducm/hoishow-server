class Operation::HelpsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_help, except: [:sort, :index, :new, :create]

  def index
    @helps = Help.order(:position) 
  end

  def new
    @help = Help.new
  end

  def create
    @help = Help.create(help_params)
    if @help.errors.any?
      flash[:alert] = @help.errors.full_messages.to_sentence
      render :new
    else
      flash[:notice] = "创建成功" 
      redirect_to operation_helps_url
    end
  end

  def show
  end

  def sort
    if params[:help].present?
      params[:help].each_with_index do |id, index|
        Help.where(id: id).update_all(position: index+1)
      end
    end
    render nothing: true
  end

  def edit
  end

  def update
    if @help.update(help_params)
      redirect_to action: :index
      flash[:notice] = "更新成功" 
    else
      flash[:alert] = @help.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @help.destroy
    redirect_to action: :index
  end

  protected
  def get_help
    @help = Help.find(params[:id])
  end

  def help_params
    params.require(:help).permit(:name, :description, :position)
  end
end
