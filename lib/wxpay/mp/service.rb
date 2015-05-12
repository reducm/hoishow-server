module Wxpay
  module Mp
    module Service
      extend Wxpay::Logger
      extend self

      def prepay(options = {})
        query_url = "https://api.mch.weixin.qq.com/pay/unifiedorder"
        options.merge!(
          appid:     WxpaySetting["app"]["app_id"],
          mch_id:    WxpaySetting["app"]["mch_id"],
          nonce_str: Wxpay::Utils.noncestr
        )

        sign_string = Wxpay::Utils.opts_to_string(options)

        sign_value = Wxpay::Sign.mp_sign(sign_string)

        options = options.sort.to_h.merge!(sign: sign_value)

        post_parse_data(query_url, options)
      end

      def query_order(options = {})
        query_url = "https///api.mch.weixin.qq.com/pay/orderquery"
        options.merge!(
          appid:     WxpaySetting["app"]["app_id"],
          mch_id:    WxpaySetting["app"]["mch_id"],
          nonce_str: Wxpay::Utils.noncestr
        )

        options.merge!(
          sign: Wxpay::Sign.mp_sign(Wxpay::Utils.opts_to_string(options))
        )

        post_parse_data(query_url, options)
      end

      def refund_order(options = {})
        query_url = "https///api.mch.weixin.qq.com/secapi/pay/refund"
        options.merge!(
          appid:     WxpaySetting["app"]["app_id"],
          mch_id:    WxpaySetting["app"]["mch_id"],
          nonce_str: Wxpay::Utils.noncestr
        )
      end

      def js_payment(prepay_id)
        options = {
          appid:     WxpaySetting["app"]["app_id"],
          nonce_str: Wxpay::Utils.noncestr,
          timestamp: Wxpay::Utils.timestamp,
          sign_type: "MD5",
          package:   "prepay_id=#{ prepay_id }"
        }

        js_options = {
          appId:     options[:app_id],
          nonceStr:  options[:nonce_str],
          timeStamp: options[:timestamp],
          package:   options[:package],
          signType:  options[:sign_type]
        }

        options.merge!(
          pay_sign: Wxpay::Sign.mp_sign(Wxpay::Utils.opts_to_string(js_options))
        )
      end

      def post_parse_data(query_url, options = {})
        begin
          wepay_data = RestClient.post query_url, Wxpay::Utils.normal_build_xml(options)
          wepay_data = Hash.from_xml(wepay_data)
          wepay_data = wrap_result(wepay_data)
          yell_logger.info "url: #{ query_url }, result: #{wepay_data["result"]}, message: #{wepay_data["message"]}"
          wepay_data
        rescue =>e
          yell_logger.info "url: #{ query_url }, result: #{e.message}, message: #{e.backtrace.join("\n")}"
          wepay_data = { "result" => "500", "message" => "服务器开小差" }
        end
      end

      def wrap_result(result)
        {
          "result" =>  result.delete("return_code").to_s,
          "message" => result.delete("return_msg"),
          "data" =>    result
        }
      end
    end
  end
end
