class Operation::MessagesController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource param_method: :message_params

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if @message.save!
      redirect_to action: :index
    else
      flash[:error] = @message.errors.full_messages
      render :new
    end
  end

  def index
    @message = Message.all
  end

  private
  def message_params
    params.require(:message).permit(:send_type, :creator_type, :creator_id, :notification_text, :title, :content, :subject_type, :subject_id)
  end

end
