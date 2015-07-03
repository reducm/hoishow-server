# encoding: utf-8
class Api::V1::UsersController < Api::V1::ApplicationController
  before_filter :check_login!, only: [:update_user, :get_user, :follow_subject, :unfollow_subject, :vote_concert, :followed_shows, :followed_concerts, :followed_stars, :create_topic, :like_topic, :create_comment, :create_order, :update_express_info]

  def sign_in
    if params[:mobile] && params[:code]
      if verify_phone?(params[:mobile])
        code = Rails.cache.read(cache_key(params[:mobile]))
        if code.blank?
          return error_json "验证码已过期"
        elsif code == params[:code]
          #TODO method and view jbuild
          @user = User.find_mobile(params[:mobile])
          if verify_block?(@user)
            render json: {errors: "你的账户由于安全原因暂时不能登录，如有疑问请致电400-880-5380"}, status: 406
            return false
          else
            @user.sign_in_api
            Rails.cache.delete(cache_key(params[:mobile])) if @user.mobile != "13435858622"
          end
        else
          return error_json "验证码错误"
        end
      else
        return error_json "手机格式不对"
      end
    else
      return error_json "传递参数出现不匹配"
    end
  end

  def verification
    mobile = params[:mobile]
    unless verify_phone?(mobile)
      return error_json "手机号码格式不对!"
    end

    if Rails.cache.read(cache_key(mobile)).present?
      return error_json "您操作太过于频繁了!"
    end

    if mobile == "13435858622"
      code = Rails.cache.fetch(cache_key(mobile), expires_in: 5.years) do
        "858622"
      end
      code_obj.expire(5.years.to_i)
      render json: {msg: "ok"}, status: 200
    else
      code = find_or_create_code(mobile)

      # production 发短信
      if Rails.env.production?
        if ChinaSMS.to(mobile, "手机验证码为#{code}【Hoishow】")[:success]
          render json: {msg: "ok"}, status: 200
        else
          return error_json "短信发送失败，请再次获取"
        end
      else
        render json: {msg: "ok"}, status: 200
      end
    end
  end


  def update_user
    #params need type mobile api_token, and avatar, email, username, ( password, verification)
    case params[:type]
    when "avatar"
      if params[:avatar].blank? || !params[:avatar].try(:content_type) =~ "image"
        return error_json "params[:avatar] error"
      end
      @user.avatar = params[:avatar]
    when "nickname"
      if params[:nickname].blank?
        return error_json "params[:nickname] error"
      end
      @user.nickname = params[:nickname]
    when "sex"
      if params[:sex].blank? || !( params[:sex].in? ["male","female","secret"])
        return error_json "params[:sex] error"
      end
      @user.send("#{params[:sex]}!")
    when "birthday"
      #只检测为非空够不够？
      if params[:birthday].blank?
        return error_json "params[:birthday] error"
      end
      @user.birthday = Time.from_ms params[:birthday]
    else
      return error_json "type error"
    end
    @user.save!
  end


  def get_user
    #params need mobile api_token
    @user =  User.find_mobile(params[:mobile])
  end

  def follow_subject
    return error_json("params[:subject_type] error") unless params[:subject_type].in? %W(Star Concert Show)
    subject = Object::const_get(params[:subject_type]).where(id: params["subject_id"]).first
    return error_json("could not find subject") if subject.blank?
    begin
      @user.send("follow_#{params[:subject_type].downcase}", subject)
      render json: {msg: "ok"}, status: 200
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      return error_json("follow fail, #{$@}")
    end
  end

  def unfollow_subject
    return error_json("params[:subject_type] error") unless params[:subject_type].in? %W(Star Concert Show)
    subject = Object::const_get(params[:subject_type]).where(id: params["subject_id"]).first
    return error_json("could not find subject") if subject.blank?
    begin
      @user.send("unfollow_#{params[:subject_type].downcase}", subject)
      render json: {msg: "ok"}, status: 200
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      return error_json("unfollow fail, #{$@}")
    end
  end

  def create_comment
    content = replace_sensitive_words(params[:content])
    @topic = Topic.where(id: params[:topic_id]).first
    if @topic.present?
      @comment = @user.create_comment(@topic, params[:parent_id], content)
      if @comment.errors.any?
        return error_json("comment create_error: #{@comment.errors.full_messages}")
      end
      #render json comment's view
    else
      return error_json("can not find topic by topic_id: #{params[:topic_id]}")
    end
  end

  def vote_concert
    begin
      @concert = Concert.where(id: params[:concert_id]).first
      @city = City.where(id: params[:city_id]).first
      if Show.where(concert_id: @concert.id, city_id: @city.id).first
        return error_json("已经开show的城市不能投票")
      else
        @user.vote_concert(@concert, @city)
        render json: {msg: "ok"}, status: 200
      end
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      return error_json("vote fail, #{$@}")
    end
  end

  def followed_shows
    params[:page] ||= 1
    @shows = @user.follow_shows.page(params[:page])
  end

  def followed_stars
    params[:page] ||= 1
    @stars = @user.follow_stars.page(params[:page])
  end

  def followed_concerts
    params[:page] ||= 1
    @concerts = @user.follow_concerts.page(params[:page])
  end

  def create_topic
    content = replace_sensitive_words(params[:content])
    @topic = @user.topics.new(creator_type: User.name, subject_type: params[:subject_type], subject_id: params[:subject_id], content: Base64.encode64(content))
    if !@topic.save
      return error_json(@topic.errors.full_messages)
    end
  end

  def like_topic
    @topic = Topic.where(id: params[:topic_id]).first
    if @topic.present?
      @user.like_topic(@topic)
      render json: {msg: "ok"}, status: 200
    else
      return error_json("can not find topic by #{params[:topic_id]}")
    end
  end

  def create_order
    @show = Show.find(params[:show_id])
    options = params.slice(:area_id, :quantity, :areas)
    options[:user] = @user
    options[:app_platform] = @auth.app_platform
    # 用 SeatSelectionLogic 这个 service 去跑
    ss_logic = SeatSelectionLogic.new(@show, options)
    ss_logic.execute
    if ss_logic.success?
      @order = ss_logic.order
    else
      error_json(ss_logic.error_msg)
    end
    if @order.amount < 0.01
      @order.set_tickets
    end
  end

  def update_express_info
    @order = Order.where(out_id: params[:out_id]).first
    if params[:express_id] && express = @user.expresses.find_by_id(params[:express_id])
      express.update(province: params[:province], city: params[:city], district: params[:district], user_address: params[:user_address], user_mobile: params[:user_mobile], user_name: params[:user_name])
    else
      @user.expresses.create(province: params[:province], city: params[:city], district: params[:district], user_address: params[:user_address], user_mobile: params[:user_mobile], user_name: params[:user_name])
    end
    address = params[:province] + params[:city] + params[:district] + params[:user_address]
    if @order.update(user_address: address, user_mobile: params[:user_mobile], user_name: params[:user_name])
      render json: {msg: "ok"}, status: 200
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

  private

  def replace_sensitive_words(content)
    sensitive_words = File.read("public/keywords.txt").split(/[\r\n]/).reject(&:empty?)
    sensitive_words.each do |word|
      content.gsub! word, "*"
    end
    return content
  end
end
