class Boombox::Operation::BoomAlbumsController < Boombox::Operation::ApplicationController
  load_and_authorize_resource

  def index
    # 先有艺人再上传
    unless params[:collaborator_id].present?
      redirect_to boombox_operation_collaborators_url
    end

    # 显示
    params[:page] ||= 1
    @boom_albums = BoomAlbum.where(collaborator_id: params[:collaborator_id]).order(is_cover: :desc, created_at: :desc).page(params[:page])
    # 上传
    @collaborator = Collaborator.find(params[:collaborator_id])
    @boom_album = BoomAlbum.new
  end

  def create
    @collaborator = Collaborator.find(params[:boom_album][:collaborator_id])
    @boom_album = @collaborator.boom_albums.new(boom_album_params)
    if @boom_album.save
      # set cover
      @boom_albums = BoomAlbum.where(collaborator_id: @collaborator.id)
      @boom_albums.update_all(is_cover: false)
      @boom_album.update(is_cover: true)

      respond_to do |format|
        flash[:notice] = '上传成功'
        format.json {render nothing: true}
      end
    else
      flash[:alert] = @boom_album.errors.full_messages
      redirect_to boombox_operation_boom_albums_url(collaborator_id: @collaborator.id)
    end
  end

  def set_cover
    @boom_album.update(is_cover: true)
    flash[:notice] = "设置封面成功"
    redirect_to boombox_operation_boom_albums_url(collaborator_id: @boom_album.collaborator.id)
  end

  def unset_cover
    @boom_album.update(is_cover: false)
    flash[:notice] = "取消封面成功"
    @collaborator = Collaborator.find(params[:collaborator_id])
    warn_if_current_no_cover(@collaborator)

    redirect_to boombox_operation_boom_albums_url(collaborator_id: @boom_album.collaborator.id)
  end

  def destroy
    @boom_album.destroy
    flash[:notice] = "相片删除成功"
    @collaborator = Collaborator.find(params[:collaborator_id])
    warn_if_current_no_cover(@collaborator)

    redirect_to boombox_operation_boom_albums_url(collaborator_id: @boom_album.collaborator.id)
  end

  private

  def boom_album_params
    params[:boom_album][:image] = params[:file]
    params.require(:boom_album).permit(:collaborator_id, :image, :is_cover)
  end

  def warn_if_current_no_cover(collaborator)
    unless collaborator.boom_albums.where(is_cover: true).any?
      flash[:warning] = "艺人当前没有封面，请设置或上传"
    end
  end
end
