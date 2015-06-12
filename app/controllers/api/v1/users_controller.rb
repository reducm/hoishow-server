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
            return error_json "您的账户由于安全问题暂时不能登录，请稍后再试"
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
    if !verify_phone?(mobile)
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

      #TODO production 发短信
      if true #ChinaSMS.to(mobile, "手机验证码为#{code}【单车电影】")[:success]
        render json: {msg: "ok"}, status: 200
      else
        return error_json "短信发送失败，请再次获取"
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
    return error_json("params[:subject_type] error") if !params[:subject_type].in? %W(Star Concert Show)
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
    return error_json("params[:subject_type] error") if !params[:subject_type].in? %W(Star Concert Show)
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
    @topic = Topic.where(id: params[:topic_id]).first
    if @topic.present?
      @comment = @user.create_comment(@topic, params[:parent_id], params[:content])
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
    @topic = @user.topics.new(creator_type: User.name, subject_type: params[:subject_type], subject_id: params[:subject_id], content: Base64.encode64(params[:content]))
    @topic.city_id = params[:city_id] if params[:city_id]
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

    if @show.selected?  #只能选区
      @relation = ShowAreaRelation.where(show_id: @show.id, area_id: params[:area_id]).first

      if @show.area_seats_left(@relation.area) - params[:quantity].to_i < 0
        return error_json("购买票数大于该区剩余票数!")
      end

      relations ||= []
      params[:quantity].to_i.times{relations.push @relation}

      @relation.with_lock do
        if @relation.is_sold_out
          return error_json("你所买的区域暂时不能买票, 请稍后再试")
        else
          @order = @user.orders.init_from_show(@show)
          @order.set_tickets_and_price(relations)
          @relation.reload
          if @show.area_seats_left(@relation.area) == 0
            @relation.update_attributes(is_sold_out: true)
          end
        end
      end
    elsif @show.selectable? #可以选座
      @order = @user.orders.init_from_show(@show)
      @order.save
      areas = JSON.parse params[:areas]
      areas.each do |area_array|
        area = @show.areas.find_by_id(area_array['area_id'])
        Seat.transaction do
          area_array['seats'].each do |seat_array|
            seat = area.seats.find_by_id(seat_array['id'])
            seat.with_lock do
              seat.update(status: :locked, order_id: @order.id)
              @order.set_tickets_info(seat)
              @order.update(amount: @order.tickets.sum(:price))
            end
          end
        end
      end
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
end
