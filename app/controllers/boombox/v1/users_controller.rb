class Boombox::V1::UsersController < Boombox::V1::ApplicationController
  before_filter :check_login!, except: [:verification, :verified_mobile, :sign_up, :sign_in, :forgot_password]
  before_filter :verify_mobile, only: [:verification, :verified_mobile, :sign_up, :forgot_password, :reset_mobile]

  def verification
    mobile = params[:mobile]
    if Rails.cache.read(cache_key(mobile)).present?
      error_respond I18n.t("errors.messages.repeat_too_much")
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
          # 播霸新用户注册时给个boom_id？
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
        error_respond I18n.t("errors.messages.password_not_correct")
      end
    else
      error_respond I18n.t("errors.messages.parameters_not_correct")
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
        error_respond I18n.t("errors.messages.mobile_code_not_correct")
      end
    else
      error_respond I18n.t("errors.messages.parameters_not_correct")
    end
  end

  def reset_password
    if @user.password_valid?(params[:current_password])
      if params[:password].blank? || params[:password_confirmation].blank?
        error_respond I18n.t("errors.messages.password_can_not_be_blank")
      else
        if params[:password_confirmation] == params[:password]
          @user.set_password(params[:password])
          render json: { result: "success" }
        else
          error_respond I18n.t("errors.messages.password_can_not_confirm")
        end
      end
    else
      error_respond I18n.t("errors.messages.current_password_not_correct")
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
        error_respond I18n.t("errors.messages.mobile_code_not_correct")
      end
    else
      error_respond I18n.t("errors.messages.parameters_not_correct")
    end
  end

  def get_user
    render partial: "user", locals:{ user: @user }
  end

  def followed_collaborators
    @collaborators = @user.follow_collaborators.verified
  end

  def followed_playlists
    @playlists = @user.follow_playlists
  end

  def my_playlists
    @playlists = BoomPlaylist.where(creator_type: BoomPlaylist::CREATOR_USER, creator_id: @user.id)
  end

  def comment_list
    user_comment_ids = BoomComment.where(creator_type: BoomComment::CREATOR_USER, creator_id: @user.id).pluck(:id)
    @comments = BoomComment.where("parent_id in (?)", user_comment_ids)
  end

  #def message_list
  #end

  def follow_subject
    error_message, subject = find_meta_subject(%W(Collaborator BoomPlaylist))
    unless subject
      return error_respond error_message
    end
    is_follow = params[:follow] ? 'follow' : 'unfollow'
    invoke_meta_method(is_follow, subject)
  end

  def create_comment
    if params[:topic_id] && params[:content]
      options = { creator_type: BoomComment::CREATOR_USER, creator_id: @user.id, content: params[:content], boom_topic_id: params[:topic_id] }
      if params[:parent_id]
        options.merge!(parent_id: params[:parent_id])
        @comment = BoomComment.create(options)
      else
        @comment = BoomComment.create(options)
      end
    else
      error_respond I18n.t("errors.messages.parameters_not_correct")
    end
  end

  def like_subject
    error_message, subject = find_meta_subject(%W(BoomTopic BoomComment))
    unless subject
      return error_respond error_message
    end
    is_like = params[:like] ? 'like' : 'unlike'
    invoke_meta_method(is_like, subject)
  end

  def add_or_remove_track_belong_to_playlist
    if params[:playlist_id] && params[:track_id] && params[:type]
      playlist = BoomPlaylist.find_by_id(params[:playlist_id])
      if playlist
        if params[:type] == 'add'
          playlist.playlist_track_relations.where(boom_track_id: params[:track_id]).first_or_create!
        elsif params[:type] == 'remove'
          relation = playlist.playlist_track_relations.where(boom_track_id: params[:track_id]).first
          if relation
            relation.destroy!
          else
            return error_respond I18n.t("errors.messages.track_not_found")
          end
        end
        render json: { result: "success" }
      else
        error_respond I18n.t("errors.messages.playlist_not_found")
      end
    else
      error_respond I18n.t("errors.messages.parameters_not_correct")
    end
  end

  def add_or_remove_playlist
    if params[:type] == 'add'
      if params[:name].present?
        @playlist = @user.boom_playlists.create(name: params[:name])
        render partial: 'boombox/v1/playlists/playlist', locals: {playlist: @playlist}
      else
        error_respond I18n.t("errors.messages.playlist_name_can_not_blank")
      end
    elsif params[:type] == 'remove'
      playlist = BoomPlaylist.find_by_id(params[:playlist_id])
      if playlist && playlist.destroy!
        render json: { result: "success" }
      else
        error_respond I18n.t("errors.messages.playlist_not_found")
      end
    end
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
      error_respond I18n.t("errors.messages.mobile_not_right")
    end
  end

  def invoke_meta_method(method_prefix, subject)
    begin
      @user.send("#{method_prefix}_#{params[:subject_type].downcase}", subject)
      render json: { result: "success" }
    rescue => e
      error_respond e
    end
  end

  def find_meta_subject(model_string_array)
    if params[:subject_type].in? model_string_array
      subject = Object::const_get(params[:subject_type]).where(id: params[:subject_id]).first
      if subject.blank?
        return I18n.t("errors.messages.subject_not_found"), false
      else
        return false, subject
      end
    else
      return I18n.t("errors.messages.subject_type_not_correct"), false
    end
  end
end
