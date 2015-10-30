class Boombox::Operation::BoomAlbumsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @boom_albums = BoomAlbum.where(collaborator_id: params[:collaborator_id]) 
  end

  def show
  end

  def new
    @
  end

  def create
  end

  def edit
  end

  def update 
  end

  def set_is_cover 
    #@boom_albums = boom_album.where("star_token = ? OR star_id = ?", @star.token, @star.id)
    #@boom_albums.update_all(is_main: false)
    #@boom_album.update(is_main: true)
    #redirect_to edit_operation_star_url(@star)
  end

  def destroy
  #  @boom_album.destroy
    #unless @star.boom_albums.is_main.any?
      #flash[:warning] = "明星没有主视频，请设置或上传" 
    #end
  #  redirect_to edit_operation_star_url(@star)
  end

  private

  def boom_album_params
  end
end
