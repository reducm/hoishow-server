class Boombox::V1::UsersController < Boombox::V1::ApplicationController
  before_filter :check_login!, except: [:verification, :verified_mobile, :sign_up, :sign_in, :forgot_password]
  before_filter :verify_mobile, only: [:verification, :verified_mobile, :sign_up, :forgot_password, :reset_mobile]

  def verification
    mobile = params[:mobile]
    if Rails.cache.read(cache_key(mobile)).present?
      return error_respond I18n.t("errors.messages.repeat_too_much")
    else
      sms_send_code(mobile)    
    end
  end

  def verified_mobile
    mobile = params[:mobile]
    user = User.where(mobile: mobile).first
    if user.blank?
      render json: { is_member: false, mobile: mobile }  
    else
      render json: { is_member: true, mobile: mobile }  
    end
  end

  #验证码正确则创建用户
  def sign_up
    if params[:code] && params[:mobile] && params[:password]
      code = find_or_create_code(params[:mobile])
      if params[:code] == code
        @user = User.create(mobile: params[:mobile])
        if @user
          @user.sign_in_api
          @user.set_password(params[:password])
        end
      else
        return error_respond I18n.t("errors.messages.mobile_code_not_correct")
      end
    else
      return error_respond I18n.t("errors.messages.parameters_not_correct")
    end
    render partial: "user", locals:{ user: @user }
  end

  def sign_in
    if params[:mobile] && params[:password]
      @user = User.find_by_mobile(params[:mobile])
      if @user.password_valid?(params[:password])
        render partial: "user", locals:{ user: @user }
      else
        return error_respond I18n.t("errors.messages.password_not_correct")
      end
    else
      return error_respond I18n.t("errors.messages.parameters_not_correct")
    end
  end

  #验证码正确则修改用户密码
  def forgot_password
    if params[:code] && params[:mobile] && params[:password]
      code = find_or_create_code(params[:mobile])
      if params[:code] == code
        @user = User.find_by_mobile(params[:mobile])
        if @user
          @user.sign_in_api
          @user.set_password(params[:password])
          render partial: "user", locals:{ user: @user }
        end
      else
        return error_respond I18n.t("errors.messages.mobile_code_not_correct")
      end
    else
      return error_respond I18n.t("errors.messages.parameters_not_correct")
    end
  end

  def reset_password
    if @user.password_valid?(params[:current_password])
      if params[:password].blank? || params[:password_confirmation].blank?
        return error_respond I18n.t("errors.messages.password_can_not_be_blank")
      else
        if params[:password_confirmation] == params[:password]
          @user.set_password(params[:password])
          render json: { result: "success" }
        else
          return error_respond I18n.t("errors.messages.password_can_not_confirm")
        end
      end
    else
      return error_respond I18n.t("errors.messages.current_password_not_correct")
    end
  end

  def update_user
    case params[:type]
    when "avatar"
      if params[:avatar].blank? || !params[:avatar].try(:content_type) =~ "image"
        return error_respond I18n.t("errors.messages.avatar_not_found")
      else
        @user.update(avatar: params[:avatar])
      end
    when "nickname"
      if params[:nickname].blank?
        return error_respond I18n.t("errors.messages.nickname_not_found")
      else
        @user.update(nickname: params[:nickname])
      end
    when "email"
      if params[:email].blank?
        return error_respond I18n.t("errors.messages.email_not_found")
      else
        unless verify_email?(params[:email])
          return error_respond I18n.t("errors.messages.email_format_wrong")
        end
        @user.update(email: params[:email])
      end
    else
      return error_respond I18n.t("errors.messages.update_user_type_not_correct")
    end
    render partial: "user", locals:{ user: @user }
  end

  def reset_mobile
    if params[:code] && params[:mobile]
      code = find_or_create_code(params[:mobile])
      if params[:code] == code
        @user.update(mobile: params[:mobile])
        render partial: "user", locals:{ user: @user }
      else
        return error_respond I18n.t("errors.messages.mobile_code_not_correct")
      end
    end
  end

  def get_user
    render partial: "user", locals:{ user: @user }
  end

  def followed_collaborators
    @collaborators = @user.follow_collaborators.verified
  end

  def followed_playlists

  end

  def my_playlists

  end

  def comment_list

  end

  def message_list

  end

  def follow_subject
    return error_respond(I18n.t("errors.messages.subject_type_not_correct")) unless params[:subject_type].in? %W(Collaborator BoomPlaylist)
    subject = Object::const_get(params[:subject_type]).where(id: params[:subject_id]).first
    return error_respond(I18n.t("errors.messages.subject_not_found")) if subject.blank?
    begin
      @user.send("follow_#{params[:subject_type].downcase}", subject)
      render json: { result: "success" }
    rescue => e
      return error_respond e
    end
  end

  def unfollow_subject
    return error_respond(I18n.t("errors.messages.subject_type_not_correct")) unless params[:subject_type].in? %W(Collaborator BoomPlaylist)
    subject = Object::const_get(params[:subject_type]).where(id: params[:subject_id]).first
    return error_respond(I18n.t("errors.messages.subject_not_found")) if subject.blank?
    begin
      @user.send("unfollow_#{params[:subject_type].downcase}", subject)
      render json: { result: "success" }
    rescue => e
      return error_respond e
    end
  end

  def create_comment

  end
   
  def like_subject

  end

  def unlike_subject

  end

  def add_to_playlist

  end

  def create_playlist

  end

  protected
  def find_or_create_code(mobile)
    code = Rails.cache.read(cache_key(mobile))
    if code.blank?
      code = Rails.cache.fetch(cache_key(mobile), expires_in: 1.minutes) do
        Rails.env.production? ? (rand(900_000)+100_000).to_s : "123456"
      end
    end
    code
  end

  def cache_key(mobile)
    "user_code_#{mobile}"
  end

  def sms_send_code(mobile)
    code = find_or_create_code(mobile)
    # production 发短信
    if Rails.env.production?
      if ChinaSMS.to(mobile, "手机验证码为#{code}【播霸】")[:success]
        render json: { result: "success" }
      else
        return error_respond I18n.t("errors.messages.sms_failed")
      end
    else
      render json: { result: "success" }
    end
  end

  def verify_mobile
    unless verify_phone?(params[:mobile])
      return error_respond I18n.t("errors.messages.mobile_not_right")
    end
  end

end
