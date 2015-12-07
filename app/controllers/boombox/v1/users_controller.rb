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
    if user
      render json: { is_member: true, mobile: mobile }
    else
      render json: { is_member: false, mobile: mobile }
    end
  end

  #验证码正确则创建用户
  def sign_up
    if params[:code] && params[:mobile] && params[:password]
      return error_respond I18n.t("errors.messages.mobile_duplicate") if User.where(mobile: params[:mobile]).any?

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
    return error_respond(I18n.t("errors.messages.email_format_wrong")) if params[:email].present? && !verify_email?(params[:email])
    return error_respond(I18n.t("errors.messages.nickname_duplicate")) if params[:nickname].present? && User.where(nickname: params[:nickname]).any?

    if @user.update(user_params)
      render partial: "user", locals:{ user: @user }
    else
      error_respond(I18n.t("update_user_type_not_correct"))
    end
  end

  def reset_mobile
    if params[:code] && params[:mobile]
      return error_respond I18n.t("errors.messages.mobile_duplicate") if User.where(mobile: params[:mobile]).any?

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
    @collaborators = @user.follow_collaborators.verified.page(params[:page])
  end

  def followed_playlists
    @playlists = @user.follow_playlists.page(params[:page])
  end

  def my_playlists
    @playlists = @user.boom_playlists.order('is_default, created_at desc').page(params[:page])
  end

  def comment_list
    user_comment_ids = BoomComment.where(creator_type: BoomComment::CREATOR_USER, creator_id: @user.id).pluck(:id)
    @comments = if params[:last]
                  BoomComment.where("parent_id in (?) and id < ?", user_comment_ids, params[:last]).first(10)
                else
                  BoomComment.where("parent_id in (?)", user_comment_ids).first(10)
                end
  end

  def message_list
    @messages = if params[:last]
                  @user.boom_messages.manual.where("boom_messages.id < ?", params[:last]).first(10)
                else
                  @user.boom_messages.manual.first(10)
                end
  end

  def follow_subject
    error_message, subject = find_meta_subject(%W(Collaborator BoomPlaylist))
    unless subject
      return error_respond error_message
    end
    is_follow = params[:follow] == 'true' ? 'follow' : 'unfollow'
    invoke_meta_method(is_follow, subject)
  end

  def create_comment
    if params[:topic_id] && params[:content]
      options = { creator_type: BoomComment::CREATOR_USER, creator_id: @user.id, content: params[:content], boom_topic_id: params[:topic_id] }
      if params[:parent_id]
        options.merge!(parent_id: params[:parent_id])
        @comment = BoomComment.create(options)
        @comment.send_reply_push
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
    is_like = params[:like] == 'true' ? 'like' : 'unlike'
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
        @playlist = @user.boom_playlists.playlist.create(name: params[:name])
        render partial: 'boombox/v1/playlists/playlist', locals: {playlist: @playlist}
      else
        error_respond I18n.t("errors.messages.playlist_name_can_not_blank")
      end
    elsif params[:type] == 'remove'
      playlist = BoomPlaylist.find_by_id(params[:playlist_id])

      if playlist
        return error_respond I18n.t("errors.messages.cannot_remove_default_playlist") if playlist.is_default

        playlist.destroy!
        render json: { result: "success" }
      else
        error_respond I18n.t("errors.messages.playlist_not_found")
      end
    end
  end

  def listened
    relation = @user.user_track_relations.where(boom_track_id: params[:track_id]).first_or_create
    relation.increment(:play_count).save!
    render json: { result: "success" }
  end

  def like_track
    @track = BoomTrack.find_by_id(params[:track_id])
    @like_playlist = @user.boom_playlists.default
    if @track && @like_playlist
      case
      when params[:type] == 'add' && @track.is_liked?(@user)
        error_respond I18n.t("errors.messages.track_already_liked")
      when params[:type] == 'remove' && !@track.is_liked?(@user)
        error_respond I18n.t("errors.messages.track_is_not_liked")
      when params[:type] == 'add' && !@track.is_liked?(@user)
        @like_playlist.tracks << @track
      when params[:type] == 'remove' && @track.is_liked?(@user)
        @like_playlist.playlist_track_relations.where(boom_track_id: @track.id).first.destroy
      else
        return error_respond I18n.t("errors.messages.data_status_error")
      end
      render partial: "boombox/v1/tracks/track", locals:{ track: @track, user: @user }
    else
      error_respond I18n.t("errors.messages.track_not_found")
    end
  end

  def check_tracks_status
    tracks = BoomTrack.where(id: params[:track_ids].split(','))

    render json: tracks.map{|track| {id: track.id, is_liked: track.is_liked?(@user)}}
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

  def user_params
    options = params.except(:action, :controller)
    options.permit(:nickname, :email, :avatar)
  end
end
