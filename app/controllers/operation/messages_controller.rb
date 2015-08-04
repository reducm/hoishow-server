# encoding: utf-8
class Operation::MessagesController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    users_array = get_users(@message)
    result = @message.send_umeng_message(users_array)
    if result == "success"
      flash[:notice] = "消息推送成功"
    else
      flash[:alert] = "消息推送失败"
    end

    redirect_to operation_messages_url
  end

  def index
    params[:page] ||= 1
    @messages = Message.page(params[:page]).order("created_at desc")
  end

  def send_umeng_message_again
    @message = Message.find(params[:id])
    users_array = get_users(@message)
    if @message.send_umeng_message(users_array) == "success"
      flash[:notice] = "推送发送成功"
    else
      flash[:alert] = "推送发送失败"
    end
    redirect_to operation_messages_url
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
