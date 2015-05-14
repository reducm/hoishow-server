# coding: utf-8
module Wxpay
  module Notify
    extend Wxpay::Logger
    extend self

    def verify?(query_params = {}, post_params = {})
      package_verify?(query_params) && signature_verify?(post_params)
    end

    def package_verify?(options = {})
      sign = options.delete("sign")
      sign == Wxpay::Sign.package_sign(Wxpay::Utils.opts_to_string(options))
    end

    def signature_verify?(options = {})
      app_signature = options.delete(:AppSignature)
      sign_method = options.delete(:SignMethod)
      options.merge!(AppKey: WxpaySetting["app"]["app_key"])
      app_signature == Wxpay::Sign.signature_sign(Wxpay::Utils.opts_key_down_case_string(options))
    end

    def mp_verify?(options = {})
      sign = options.delete("sign")
      sign == Wxpay::Sign.mp_sign(Wxpay::Utils.opts_to_string(options))
    end
  end
end
