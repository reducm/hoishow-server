class Boombox::Dj::BoomAlbumsController < Boombox::Dj::ApplicationController
  before_filter :check_login!

  def index
    # 显示
    params[:page] ||= 1
    @boom_albums = current_collaborator.boom_albums.order(is_cover: :desc, created_at: :desc).page(params[:page])
    # 上传
    @boom_album = current_collaborator.boom_albums.new
  end

  def create
    @boom_album = current_collaborator.boom_albums.new(create_params)

    if @boom_album.save
      set_cover

      respond_to do |format|
        flash[:notice] = '上传成功' 
        format.json {render nothing: true}
      end
    else
      flash[:alert] = @boom_album.errors.full_messages 
      redirect_to boombox_dj_boom_albums_url(collaborator_id: current_collaborator.id)
    end
  end

  def toggle_cover
    @boom_album = BoomAlbum.find(params[:id])

    if @boom_album.is_cover?
      @boom_album.update(is_cover: false)
      flash[:notice] = "取消封面成功" 
      warn_if_current_no_cover(current_collaborator)
      redirect_to boombox_dj_boom_albums_url(collaborator_id: current_collaborator.id)
    else
      set_cover
      flash[:notice] = "设置封面成功"
      redirect_to boombox_dj_boom_albums_url(collaborator_id: current_collaborator.id)
    end
  end

  def destroy
    @boom_album = BoomAlbum.find(params[:id])
    @boom_album.destroy
    flash[:notice] = "相片删除成功"
    warn_if_current_no_cover(current_collaborator)

    redirect_to boombox_dj_boom_albums_url(collaborator_id: current_collaborator.id)
  end

  private

  def create_params
    params[:boom_album][:image] = params[:file]
    params.require(:boom_album).permit(:collaborator_id, :image, :is_cover)
  end

  def warn_if_current_no_cover(collaborator)
    unless collaborator.boom_albums.where(is_cover: true).any?
      flash[:warning] = "艺人当前没有封面，请设置或上传"
    end
  end

  def set_cover
    current_collaborator.boom_albums.update_all(is_cover: false)
    @boom_album.update(is_cover: true)
  end
end
