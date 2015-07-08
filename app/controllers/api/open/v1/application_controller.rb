# encoding: utf-8
class Api::Open::V1::ApplicationController < ApplicationController
  before_filter :api_verify

  protected
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
    if Time.now - Time.at(params[:timestamp].to_i) > 600
      return render json: {result_code: "1002", message: "签名验证不通过"}
    end

    #文档中的必需参数
    options = [
      "api_key",
      "timestamp",
      "show_id",
      "area_id",
      "user_id",
      "mobile",
      "quantity",
      "reason"
    ]
    #如果传入的参数是文档中规定的必需参数
    #将其组成字符串，格式为"key1=value1&key2=value2&...secretcode"
    #对字符串md5加密，加密后转成大写
    options = params.select {|key,value| options.include? key}
    signing_string = options.sort.to_h.map{|key, value| "#{key.to_s}=#{value}"}.join("&") << @auth.secretcode
    signing_string = Digest::MD5.hexdigest(signing_string).upcase
    if params[:sign] != signing_string
      return render json: {result_code: "1002", message: "签名验证不通过"}
    end
  end
end
