# encoding: utf-8
class Api::Open::V1::ApplicationController < ApplicationController
  before_filter :api_verify

  protected
  def api_verify
    return true if Rails.env.development?

    if params[:api_key].blank? || params[:sign].blank? || params[:timestamp].blank?
      render json: {result_code: "1003", errors: "缺少必要的参数"}, status: 403
    end

    @auth = Rails.cache.fetch("api_auth_#{params[:api_key]}") do
      ApiAuth.where(key: params[:api_key]).first
    end
    unless @auth
      render json: {result_code: "1001", errors: "商户信息不存在"}, status: 403
    end

    if Time.now - Time.from_ms(params[:timestamp]) > 600
      render json: {result_code: "1002", errors: "签名验证不通过"}, status: 403
    end

    if params[:sign] != Digest::MD5.hexdigest("api_key=#{@auth.key}&timestamp=#{params[:timestamp]}#{@auth.secretcode}")
      render json: {result_code: "1002", errors: "签名验证不通过"}, status: 403
    end
  end
end
