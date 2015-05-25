class Api::V1::MessagesController < Api::V1::ApplicationController
  before_action :check_login!

  def index
    if params[:type] == "system"
      @messages = Message.system_messages
    elsif params[:type] == "reply"
      @messages = Message.reply_messages
    end
  end
end
