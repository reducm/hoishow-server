class Operation::MessagesController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
  end

  def index
    @message = Message.all
  end

  private
  def message_params
    params.require(:message).permit(:creator_type, :creator_id, :notification_text, :tile, :content, :subject_type, :subject_id)
  end

end
