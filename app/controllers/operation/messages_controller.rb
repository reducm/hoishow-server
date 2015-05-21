class Operation::MessagesController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource param_method: :message_params

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    content = ""
    users_array = []

    case @message.creator_type
    when "Star"
      users_array = @message.creator.followers
    when "Concert"
      users_array = @message.creator.followers
    when "Show"
      users_array = @message.creator.show_followers
    when "All"
      users_array = User.all
    end

    if ( result = @message.send_umeng_message(users_array, @message)) != "success"
      flash[:alert] = result
    end

    redirect_to action: :index
  end

  def index
    @message = Message.all
  end

  private
  def message_params
    params.require(:message).permit(:send_type, :creator_type, :creator_id, :notification_text, :title, :content, :subject_type, :subject_id)
  end

end
