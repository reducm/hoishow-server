class Boombox::Dj::CollaboratorsController < Boombox::Dj::ApplicationController
  before_filter :check_login!, except: [:new, :create]

  def new
    @collaborator = Collaborator.new 
    @boom_admin = BoomAdmin.find(params[:boom_admin_id])
  end

  def create
    @boom_admin = BoomAdmin.find(params[:collaborator][:boom_admin_id])
    @collaborator = Collaborator.new(create_params) 
    if @collaborator.save
      redirect_to boombox_dj_signup_finished_url(collaborator_id: @collaborator.id), notice: '个人资料保存成功'
    else
      flash[:alert] = @collaborator.errors.full_messages.to_sentence
      render action: 'new', boom_admin_id: @boom_admin.id
    end
  end

  def edit
    @collaborator = Collaborator.find(params[:id])
  end

  def update
    @collaborator = Collaborator.find(params[:id])
    if @collaborator.nickname != params[:collaborator][:nickname] && @collaborator.nickname_changeable? == false
      flash[:alert] = '昵称一个月只能修改一次'
      render action: 'edit'
    else
      if @collaborator.update(update_params)
        redirect_to boombox_dj_root_url, notice: '更新成功'
      else
        flash[:alert] = @collaborator.errors.full_messages.to_sentence
        render action: 'edit'
      end
    end
  end

  private
  def create_params
    params.require(:collaborator).permit(Collaborator.column_names.delete_if {|obj| obj.in? ["boom_id", "created_at", "updated_at"]}.map &:to_sym)
  end

  def update_params
    params.require(:collaborator).permit(Collaborator.column_names.delete_if {|obj| obj.in? ["boom_id", "created_at", "updated_at", "name", "email"]}.map &:to_sym)
  end
end
