# coding: utf-8
module Wxpay
  module Service
    extend Wxpay::Logger
    class << self
      attr_accessor :access_token, :expired_at
    end
    extend self

    def get_access_token
      if expired?
        authenticate
      end
      Wxpay::Service.access_token
    end

    def expired?
      if Wxpay::Service.expired_at.present?
        Time.now >= Wxpay::Service.expired_at
      else
        true
      end
    end

    def expired_at
      Wxpay::Service.expired_at
    end

    def authenticate
      options = {
        grant_type: "client_credential",
        appid: WxpaySetting["app"]["app_id"],
        secret: WxpaySetting["app"]["app_secret"]
      }

      query_url = "https://api.weixin.qq.com/cgi-bin/token?#{options.to_query}"

      begin
        wxpay_data = RestClient.get query_url
        wxpay_data = JSON.parse wxpay_data

        unless wxpay_data.has_key?("errcode")
          Wxpay::Service.access_token = wxpay_data["access_token"]
          Wxpay::Service.expired_at = Time.now + (wxpay_data["expires_in"].to_i - 60)
        end
      rescue => e
      end
    end

    def prepay(options = {})
      query_url = "https://api.weixin.qq.com/pay/genprepay?access_token=#{get_access_token}"

      user_id = options.delete(:user_id)

      options.merge!(
        bank_type:     "WX",
        partner:       WxpaySetting["app"]["partner_id"],
        fee_type:      "1",
        input_charset: "UTF-8"
      )

      options = {
        appid:         WxpaySetting["app"]["app_id"],
        noncestr:      Wxpay::Utils.noncestr,
        package:       Wxpay::Utils.package(options),
        timestamp:     Wxpay::Utils.timestamp,
        traceid:       user_id
      }

      signature_options = options.merge(appkey: WxpaySetting["app"]["app_key"])

      options.merge!(
        app_signature: Wxpay::Sign.signature_sign(Wxpay::Utils.opts_to_string(signature_options)),
        sign_method:   "sha1"
      )

      result_data = post_parse_data(query_url, options)

      if result_data["result"] == "0"
        options = {
          appid:     WxpaySetting["app"]["app_id"],
          noncestr:  Wxpay::Utils.timestamp,
          package:   "Sign=WXpay",
          partnerid: WxpaySetting["app"]["partner_id"],
          prepayid:  result_data["data"]["prepayid"],
          timestamp: Wxpay::Utils.timestamp,
        }

        signature_options = options.merge(appkey: WxpaySetting["app"]["app_key"])

        options.merge!(
          sign: Wxpay::Sign.signature_sign(Wxpay::Utils.opts_to_string(signature_options))
        )

        result_data["data"] = options
      end
      result_data
    end

    def query_order(options = {})
      query_url = "http://api.weixin.qq.com/cgi-bin/pay/delivernotify?access_token=#{get_access_token}"

      options = {
        appid: WxpaySetting["app"]["app_id"],
        package: Wxpay::Utils.package(options),
        timestamp: Wxpay::Utils.timestamp
      }

      signature_options = options.merge(appkey: WxpaySetting["app"]["app_key"])

      options.merge!(
        app_signature: Wxpay::Sign.signature_sign(Wxpay::Utils.opts_to_string(signature_options)),
        sign_method:   "sha1"
      )

      post_parse_data(query_url, options)
    end

    def post_parse_data(query_url, options = {})
      begin
        wepay_data = RestClient.post query_url, options.to_json
        wepay_data = JSON.parse wepay_data
        wepay_data = wrap_result(wepay_data)
        yell_logger.info "url: #{ query_url }, result: #{wepay_data["result"]}, message: #{wepay_data["message"]}"
        wepay_data
      rescue => e
        yell_logger.info "url: #{ query_url }, result: #{e.message}, message: #{e.backtrace.join("\n")}"
        wepay_data = { "result" => "500", "message" => "服务器开小差" }
      end
    end

    def wrap_result(result)
      {
        "result" =>  result.delete("errcode").to_s,
        "message" => result.delete("errmsg"),
        "data" =>    result
      }
    end
  end
end
