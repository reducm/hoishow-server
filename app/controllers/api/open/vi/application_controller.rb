# encoding: utf-8
class Api::Open::V1::ApplicationController < ApplicationController
  before_filter :api_verify

  protected
  def api_verify
    return true if Rails.env.development?

    if params[:api_key].blank? || params[:sign].blank? || params[:timestamp].blank?
      return error_json("1003: 缺少必要的参数")
    end

    @auth = Rails.cache.fetch("api_auth_#{params[:api_key]}") do
      ApiAuth.where(key: params[:api_key]).first
    end
    unless @auth
      return error_json("1001: 商户信息不存在")
    end

    if Time.now - Time.from_ms(params[:timestamp]) > 600
      return error_json("1002: 签名验证不通过") 
    end

    api_key = @auth.key 
    secretcode = @auth.secretcode 
    sign = params[:sign]
    timestamp = params[:timestamp]
    verified_sign = Digest::MD5.hexdigest("api_key=#{api_key}&secretcode=#{secretcode}&timestamp=#{timestamp}")
    if sign != verified_sign
      return error_json("1002: 签名验证不通过") 
    end
  end
end
