class Boombox::Operation::MessagesController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
    @messages = BoomMessage.manual.page(params[:page])
  end

  def new
    @message = BoomMessage.new
  end

  def create
    @message = BoomMessage.new(message_params)
    @message.subject_type = get_subject_type(params[:boom_message][:subject_type])
    if @message.save
      flash[:notice] = "消息创建成功"
      redirect_to boombox_operation_messages_url
    else
      flash[:alert] = "消息创建失败"
      render :new
    end
  end

  def push_again
    @message = BoomMessage.find params[:id]
    @message.set_message_tasks

    flash[:notice] = '重发消息成功'
    redirect_to boombox_operation_messages_url
  end

  private
  def message_params
    params.require(:boom_message).permit(:send_type, :title, :content, :subject_id, :start_time, :targets)
  end

  def get_subject_type(type)
    case type
    when 'Playlist'
      'BoomPlaylist'
    when 'Show', 'Activity'
      'BoomActivity'
    else
      type
    end
  end
end
