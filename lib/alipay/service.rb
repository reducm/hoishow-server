# coding: utf-8
module Alipay
  module Service
    def self.create_direct_pay_by_user(options)
      # params out_trade_no, subject, total_fee(price&quantity), notify_url, return_url
      options = {
        service: "create_direct_pay_by_user",
        payment_type: "1",
        partner: AlipaySetting["v2_pid"],
        seller_email: AlipaySetting["v2_email"],
        _input_charset: "utf-8"
      }.merge(options)

      if options['total_fee'].nil? and (options['price'].nil? || options['quantity'].nil?)
        warn("Ailpay Warn: total_fee or (price && quantiry) must have one")
      end

      "#{AlipaySetting["mapi_url"]}?#{query_string(options)}"
    end

    def self.wap_create_direct_pay_by_user(options)
      options = {
        service:        "alipay.wap.create.direct.pay.by.user",
        payment_type:   "1",
        partner:        AlipaySetting["v2_pid"],
        seller_id:      AlipaySetting["v2_pid"],
        _input_charset: "utf-8"
      }.merge(options)

      if options['total_fee'].nil? and (options['price'].nil? || options['quantity'].nil?)
        warn("Ailpay Warn: total_fee or (price && quantiry) must have one")
      end

      "#{AlipaySetting["mapi_url"]}?#{query_string(options)}"
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
        partner: AlipaySetting["v2_pid"],
        _input_charset: "utf-8",
        notify_url: AlipaySetting["refund_url"],
        refund_date: Alipay::Utils.timestamp,
        batch_no: Alipay::Utils.generate_batch_no,
        batch_num: data.size,
        detail_data: detail_data
      }
      req_url = "#{AlipaySetting["mapi_url"]}?#{query_string(options)}"
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
        partner: AlipaySetting["v2_pid"],
        _input_charset: "utf-8",
        notify_url: AlipaySetting["refund_url"],
        seller_email: AlipaySetting["v2_email"],
        seller_user_id: AlipaySetting["pid"],
        refund_date: Alipay::Utils.timestamp,
        batch_no: Alipay::Utils.generate_batch_no,
        batch_num: data.size,
        detail_data: detail_data
      }

      "#{AlipaySetting["mapi_url"]}?#{query_string(options)}"
    end

    def self.query_string(options)
      options.merge(sign_type: 'MD5', sign: Alipay::Sign.md5_sign(options, AlipaySetting["v2_md5_key"])).map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end
  end
end
