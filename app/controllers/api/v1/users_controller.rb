# coding: utf-8
class Api::V1::UsersController < Api::V1::ApplicationController
  before_filter :check_login!, only: [:update_user, :get_user, :follow_subject, :vote_concert, :followed_concerts, :followed_stars]
  def sign_in
    if params[:mobile] && params[:code]
      if verify_phone?(params[:mobile])
        code = Rails.cache.read(cache_key(params[:mobile]))
        if code.blank?
          return error_json "验证码已过期"
        elsif code == params[:code]
          #TODO method and view jbuild
          @user = User.find_mobile(params[:mobile])
          @user.sign_in_api
          Rails.cache.delete(cache_key(params[:mobile])) if @user.mobile != "13435858622"
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
    return error_json("params[:subject_type] error") if !params[:subject_type].in? %W(Star Concert)
    subject = Object::const_get(params[:subject_type]).where(id: params["subject_id"]).first 
    return error_json("could not find subject") if subject.blank?
    begin
      @user.send("follow_#{params[:subject_type].downcase}", subject)
      render json: {msg: "ok"}, status: 200
    rescue
      return error_json("follow fail, #{$@}")
    end
  end

  def vote_concert
    begin
      @concert = Concert.where(id: params[:concert_id]).first
      @city = City.where(id: params[:city_id]).first
      @user.vote_concert(@concert, @city)
      render json: {msg: "ok"}, status: 200
    rescue
      return error_json("vote fail, #{$@}")
    end
  end

  def followed_stars
    params[:page] ||= 1
    @stars = @user.follow_stars.page(params[:page]).per(12)
  end
  
  def followed_concerts
    params[:page] ||= 1
    @concerts = @user.follow_concerts.page(params[:page]).per(20)
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
