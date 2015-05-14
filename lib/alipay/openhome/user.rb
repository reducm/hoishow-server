# coding: utf-8
module Alipay
  module Openhome
    module User
      def self.verify(options)
        sign_string = "<success>true</success><biz_content>#{AlipaySetting["rsa_pub_key"]}</biz_content>"
        sign = Alipay::Sign.rsa_sign(sign_string, Alipay::Sign.pri_key_file)
        res_xml = <<-XML
           <?xml version="1.0" encoding="GBK"?>
             <alipay>
               <response>
                 #{sign_string}
               </response>
               <sign>#{sign}</sign>
               <sign_type>RSA</sign_type>
             </alipay>
        XML
        res_xml.gsub(/\n+/,'').strip
      end

      def self.user_info_authorize(options)
        options = {
          service: "alipay.auth.authorize",
          partner: AlipaySetting["pid"],
          _input_charset: "utf-8",
          target_service: "user.auth.qiuck.login"
        }.merge(options)

        req_url = "#{AlipaySetting["api_url"]}?#{query_string(options)}"
      end

      def self.auth_token_exchange(options)
        # params code
        options = {
          method: "alipay.system.oauth.token",
          _input_charset: "utf-8",
          grant_type: "authorization_code",
          app_id: AlipaySetting["mobile_app_id"],
          version: "1.0",
          sign_type: "RSA",
          timestamp: Alipay::Utils.timestamp
        }.merge(options)

        options.merge!(sign: Alipay::Sign.rsa_sign(
          Alipay::Utils.hash_sort_to_string(options), Alipay::Sign.pri_key_file)
        )

        req_url = "#{AlipaySetting["api_url"]}?#{options.to_query}"
        response_data = RestClient.post req_url, nil

        (JSON.parse response_data)["alipay_system_oauth_token_response"]
      end

      def self.user_share_info(options)
        # params auth_token
        options = {
          method: "alipay.user.userinfo.share",
          app_id: AlipaySetting["mobile_app_id"],
          _input_charset: "utf-8",
          version: "1.0",
          timestamp: Alipay::Utils.timestamp,
          sign_type: "RSA"
        }.merge(options)
        
        options.merge!(sign: Alipay::Sign.rsa_sign(
          Alipay::Utils.hash_sort_to_string(options), Alipay::Sign.pri_key_file)
        )

        req_url = "#{AlipaySetting["api_url"]}?#{options.to_query}"
        response_data = RestClient.post req_url, nil

        (JSON.parse response_data)["alipay_user_userinfo_share_response"]
      end

      def self.gis_get(options)
        user_id = options.delete(:user_id)
        options = {
          method: "alipay.mobile.public.gis.get",
          app_id: AlipaySetting["sandbox_app_id"],
          sign_type: "RSA",
          charset: "utf-8",
          timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
          biz_content: "{'userId': #{user_id}}"
        }.merge(options)

        options.merge!(sign: Alipay::Sign.rsa_sign(
          Alipay::Utils.hash_sort_to_string(options), Alipay::Sign.pri_key_file)
        )

        req_url = "#{AlipaySetting["api_url"]}?#{options.to_query}"
        response_data = RestClient.post req_url, nil
        JSON.parse(response_data)["alipay_mobile_public_gis_get_response"]
      end

      def self.query_string(options)
        options.merge(sign_type: 'MD5', sign: Alipay::Sign.md5_sign(options)).map do |key, value|
          "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
        end.join('&')
      end

    end
  end
end
