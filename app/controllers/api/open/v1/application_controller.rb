# encoding: utf-8
class Api::Open::V1::ApplicationController < ApplicationController
  before_filter :api_verify

  protected
  #文档中的必需参数
  def auth_params
    params.permit(  
      "api_key",
      "timestamp",
      "show_id",
      "area_id",
      "user_id",
      "mobile",
      "quantity",
      "reason"
     ) 
  end

  def api_verify
    return true if Rails.env.development?

    if params[:api_key].blank? || params[:sign].blank? || params[:timestamp].blank?
      return render json: {result_code: "1003", message: "缺少必要的参数"}
    end

    @auth = Rails.cache.fetch("api_auth_#{params[:api_key]}") do
      ApiAuth.where(key: params[:api_key]).first
    end
    unless @auth
      return render json: {result_code: "1001", message: "商户信息不存在"}
    end

    #签名中的时间戳，有效时间为10分钟
    if Time.now - Time.at(params[:timestamp]) > 600
      return render json: {result_code: "1002", message: "签名验证不通过"}
    end

    unless params[:sign] == @auth.generated_sign(auth_params) 
      return render json: {result_code: "1002", message: "签名验证不通过"}
    end
  end
end
