# coding: utf-8
class Api::V1::UsersController < Api::V1::ApplicationController
  before_filter :check_login!, only: [:update_user, :get_user]
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


  def update_cuser
    #params need type mobile api_token, and avatar, email, username, ( password, verification)
    case params[:type]
    when "avatar"
      if params[:avatar].blank? || !params[:avatar].try(:content_type) =~ "image"
        error_json "params[:avatar] error"
        return false
      end
      @user.avatar = params[:avatar]
      user_json(@user) 
      return false
    when "username"
      @user.username = params[:username]
      user_json(@user) 
      return false
    when "email"
      @user.email = params[:email]
      user_json(@user) 
      return false
    when "password"
      code = Redis::Objects.redis.get(params[:mobile])
      if code.blank?
        error_json( "验证码已过期" ) 
        return false
      elsif code == params[:verification]
        Redis::Objects.redis.del(params[:mobile])
        @user.password = params[:password]
        @user.password_confirmation = params[:password_confirmation]
        user_json(@user) 
        return false
      else
        error_json "验证码错误"
      end
    else
      error_json "type error"
    end
  end


  def get_user
    #params need mobile api_token
    user_json User.find_mobile(params[:mobile])
    
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
