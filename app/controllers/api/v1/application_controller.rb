# coding: utf-8
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

  def get_admin_from_params(name)
    admin = Admin.where(name: name).first
  end

  def check_admin_validness!
    if params[:name].blank?
      return error_json "获取验票员信息异常，请重新登陆"
    end
    @admin = get_admin_from_params(params[:name])
    return error_json "账户不存在" if @admin.blank?

    if verify_block?(@admin)
      return error_json "账户被锁定，请联系管理员"
    elsif @admin.admin_type != "ticket_checker" 
      return error_json "账户无验票权限"
    end
  end

end
