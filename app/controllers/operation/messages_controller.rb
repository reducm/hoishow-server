# encoding: utf-8
class Operation::MessagesController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource param_method: :message_params

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    content = ""
    users_array = get_users(@message)

    if ( result = @message.send_umeng_message(users_array, @message)) != "success"
      flash[:alert] = result
    end

    redirect_to action: :index
  end

  def index
    params[:page] ||= 1
    @messages = Message.page(params[:page]).order("created_at desc")
  end

  private
  def message_params
    params.require(:message).permit(:send_type, :creator_type, :creator_id, :notification_text, :title, :content, :subject_type, :subject_id)
  end

  def get_users(message)
    case message.creator_type
    when "Star" || "Concert"
      message.creator.followers
    when "Show"
      message.creator.show_followers
    when "All"
      User.all
    else
      []
    end
  end

end
