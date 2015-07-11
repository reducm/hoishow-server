# encoding: utf-8
class Open::V1::ApplicationController < ApplicationController
  before_filter :api_verify
  skip_before_filter :verify_authenticity_token

  protected
  def show_auth!
    @show = Show.where(id: params[:show_id]).first
    if @show.nil?
      not_found_respond('找不到该演出')
    end
  end

  def area_auth!
    show_auth!
    @area = @show.areas.where(id: params[:area_id]).first
    if @area.nil?
      not_found_respond('找不到该区域')
    end
  end

  # not_found warpper
  def not_found_respond(msg)
    error_respond(2001, msg)
  end

  def error_respond(code, msg)
    @error_code = code
    @message = msg
    respond_to { |f| f.json }
  end

  #文档中的必需参数
  def auth_params
    params.permit("api_key", "timestamp", "show_id", "area_id", "user_id",
      "mobile", "quantity", "reason","areas", "bike_user_id", "bike_out_id", # "out_id"
      "user_name", "user_mobile", "province", "city", "district", "address"
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
    if Time.now.to_i - params[:timestamp].to_i > 600
      return render json: {result_code: "1004", message: "请求因超时而失效"}
    end

    unless params[:sign] == @auth.generated_sign(auth_params)
      return render json: {result_code: "1002", message: "签名验证不通过"}
    end
  end

end
