# encoding: utf-8
class Api::V1::ApplicationController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :api_verify

  protected
  def api_verify
    return true if Rails.env.development?
    if params[:key].blank?
      return error_json( "Key can not be blank" )
    end

    @auth = Rails.cache.fetch("api_auth_#{params[:key]}") do
      ApiAuth.where(key: params[:key]).first
    end

    if @auth.blank?
      return error_json "no permission"
    end
  end

  #无用户参数信息时会直接返回403错误
  def check_login!
    #这里的错误返回信息会影响app判断,不能随便改
    if params[:api_token].blank? || params[:mobile].blank?
      return error_json("no_api_token_or_mobile!")
    end
    @user = get_user_from_params(params[:api_token], params[:mobile])

    if verify_block?(@user)
      render json: {errors: "你的账户由于安全原因暂时不能登录，如有疑问请致电400-880-5380"}, status: 406
      return false
    end

    return error_json("api_token_wrong") if @user.blank?
    @user
  end

  #有用户参数时会设定@user的变量
  def check_has_user
    if params[:api_token] && params[:mobile]
      @user = get_user_from_params(params[:api_token], params[:mobile])
    end
  end

  def get_user_from_params(api_token, mobile)
    user = User.where(api_token: api_token, mobile: mobile).first
  end

  def error_json(str)
    render json: {errors: str}, status: 403
    return false
  end

  def check_admin_validness!
    if params[:name].blank? || params[:api_token].blank?
      return error_json "获取验票员信息异常，请重新登陆"
    else
      @admin = Admin.where(api_token: params[:api_token], name: params[:name]).first
      if @admin.blank?
        return error_json "账户不存在"
      elsif verify_block?(@admin)
        render json: {errors: "账户被锁定，请联系管理员"}, status: 406
      elsif @admin.admin_type != "ticket_checker"
        return error_json "账户无验票权限"
      end
    end
  end
end
