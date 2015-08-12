module Alipay
  module AppService
    def self.create_direct_pay_by_user(options = {})
      options.merge!({
        service:        "mobile.securitypay.pay",
        partner:        AlipaySetting["v2_pid"],
        _input_charset: "utf-8",
        payment_type:   "1",
        seller_id:      AlipaySetting["v2_email"],
      })

      query_string(options)
    end 

    def self.query_string(options)
      options.merge!(sign_type: "RSA", sign:  CGI.escape(Alipay::Sign.rsa_sign(Alipay::Utils.app_hash_to_string(options), Alipay::Sign.pri_app_key_file)))
      Alipay::Utils.app_hash_to_string(options)
    end 
  end 
end 
