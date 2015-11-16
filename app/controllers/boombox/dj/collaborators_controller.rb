class Boombox::Dj::CollaboratorsController < Boombox::Dj::ApplicationController
  before_filter :check_login!

  def edit
    @collaborator = Collaborator.find(params[:id])
  end

  def update
    @collaborator = Collaborator.find(params[:id])
    if @collaborator.nickname_changeable?(params[:collaborator][:nickname])
      if @collaborator.update(collaborator_params)
        redirect_to boombox_dj_root_url, notice: '个人资料更新成功。'
      else
        flash[:alert] = @collaborator.errors.full_messages.to_sentence
        render action: 'edit'
      end
    else
      flash[:alert] = '昵称一个月只能改一次' 
      render action: 'edit'
    end
  end

  private
  def collaborator_params
    params.require(:collaborator).permit(Collaborator.column_names.delete_if {|obj| obj.in? ["boom_id", "created_at", "updated_at", "name", "email"]}.map &:to_sym)
  end
end
