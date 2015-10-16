class Boombox::V1::UsersController < Boombox::V1::ApplicationController
  before_filter :check_login!, except: [:verification, :verified_mobile, :sign_up, :sign_in]
  before_filter :verify_mobile, only: [:verification, :verified_mobile, :sign_up]

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
    end
    render partial: "user", locals:{ user: @user }
  end

  def sign_in

  end

  def forgot_password

  end

  def reset_password

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
        @user.update(email: params[:email])
      end
    else
      return error_respond I18n.t("errors.messages.update_user_type_not_correct")
    end
    render partial: "user", locals:{ user: @user }
  end

  def reset_mobile

  end

  def get_user

  end

  def followed_collaborators

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

  end

  def unfollow_subject

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
      if ChinaSMS.to(mobile, "手机验证码为#{code}【BoomBox】")[:success]
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
