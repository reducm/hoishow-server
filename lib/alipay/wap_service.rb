# coding: utf-8
module Alipay
  module WapService
    def self.trade_create_direct_token(options)
      options.merge!(seller_account_name: AlipaySetting["email"])
      xml = options.map {|k, v| "<#{k}>#{v}</#{k}>" }.join
      req_data_xml = "<direct_trade_create_req>#{xml}</direct_trade_create_req>"
      options = {
        service: "alipay.wap.trade.create.direct",
        format: "xml",
        sec_id: 'MD5',
        v: "2.0",
        _input_charset: "utf-8",
        partner: AlipaySetting["pid"],
        req_id: Time.now.to_ms.to_s, #时间戳作为请求号
        req_data: req_data_xml
      }

      xml = RestClient.post "#{AlipaySetting["wap_api_url"]}?#{query_string(options)}", nil
      CGI.unescape(xml).scan(/\<request_token\>(.*)\<\/request_token\>/).flatten.first
    end

    def self.auth_and_execute(options)
      req_data_xml = "<auth_and_execute_req><request_token>#{options.delete(:request_token)}</request_token></auth_and_execute_req>"
      options = {
        service: "alipay.wap.auth.authAndExecute",
        format: "xml",
        sec_id: 'MD5',
        v: "2.0",
        partner: AlipaySetting["pid"],
        req_data: req_data_xml
      }

      execute_wap_trade_url = "#{AlipaySetting["wap_api_url"]}?#{query_string(options)}"
      return execute_wap_trade_url
    end

    def self.refund_fastpay(options)
      data = options.delete(:data)
      reason = options.delete(:reason)
      detail_data = data.map do |item|
        "#{item.trade_id}^#{item.amount}^#{reason}"
      end.join('#')
      puts detail_data
      options = {
        service: "refund_fastpay_by_platform_nopwd",
        partner: AlipaySetting["pid"],
        _input_charset: "utf-8",
        notify_url: AlipaySetting["wireless_refund_url"],
        refund_date: Alipay::Utils.timestamp,
        batch_no: Alipay::Utils.generate_batch_no,
        batch_num: data.size,
        detail_data: detail_data
      }.merge(options)
      req_url = "#{AlipaySetting["mapi_url"]}?#{refund_query_string(options)}"
      puts req_url

      str = RestClient.get req_url
      puts str
      str.scan(/\<is_success\>(.*)\<\/is_success\>/).flatten.first == "T" ? true : false
    end

     def create_refund_url(options)
      data = options.delete(:data)
      reason = options.delete(:reason)
      detail_data = data.map do |item|
        "#{item.trade_id}^#{item.amount}^#{reason}"
      end.join('#')
      puts detail_data
      options = {
        service: "refund_fastpay_by_platform_pwd",
        partner: AlipaySetting["pid"],
        _input_charset: "utf-8",
        notify_url: AlipaySetting["wireless_refund_url"],
        seller_email: AlipaySetting["email"],
        seller_user_id: AlipaySetting["pid"],
        refund_date: Alipay::Utils.timestamp,
        batch_no: Alipay::Utils.generate_batch_no,
        batch_num: data.size,
        detail_data: detail_data
      }

      "#{AlipaySetting["mapi"]}?#{refund_query_string(options)}"
    end

    def self.query_string(options)
      options.merge(sign: Alipay::Sign.md5_sign(options, AlipaySetting["md5_key"])).map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end

    def self.refund_query_string(options)
      options.merge(sign_type: "MD5", sign: Alipay::Sign.md5_sign(options, AlipaySetting["md5_key"])).map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end
  end
end
