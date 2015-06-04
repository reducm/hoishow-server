# encoding: utf-8
class Api::V1::MessagesController < Api::V1::ApplicationController
  before_action :check_login!
  after_action  :set_send_log_is_new_false

  def index
    user = User.where(mobile: params[:mobile]).first
    if params[:type] != "all"
      if params[:type] == "system"
        @messages = user.messages.system_messages
      elsif params[:type] == "reply"
        @messages = user.messages.reply_messages
      else
        error_json("传递参数出现不匹配")
      end
    else
      if UserMessageRelation.where(user: user, is_new: true).any?
        render json: {msg: "yes"}, status: 200
      else
        render json: {msg: "no"}, status: 200
      end
    end
  end

  private

  def set_send_log_is_new_false
    user = User.where(mobile: params[:mobile]).first
    if params[:type] == "system"
      messages = user.messages.system_messages
      messages.each do |message|
        message.user_message_relations.update_all(is_new: false)
      end
    elsif params[:type] == "reply"
      messages = user.messages.reply_messages
      messages.each do |message|
        message.user_message_relations.update_all(is_new: false)
      end
    end
  end
end
