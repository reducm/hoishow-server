class Operation::MessagesController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource param_method: :message_params

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if @message.save!
      content = ""
      case @message.creator_type
      when "Star"
        users = @message.subject.followers
      when "Concert"
        users = @message.subject.followers
      when "Show"
        users = @message.subject.show_followers
      when "All"
        users = User.all
      end
      if users.count > 0
        users.each do |user|
          content = content + user.mobile + "\n"
        end
        task_id = @message.send_umeng_message(content, @message)
        if task_id
          @message.update!(task_id: task_id)
          redirect_to action: :index
        end
      end
      flash[:alert] = "关注用户数为0，消息创建成功，推送发送失败"
      redirect_to action: :index
    else
      flash[:alert] = @message.errors.full_messages
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
