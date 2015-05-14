# coding: utf-8
module Wxpay
  module Sign
    extend self

    def md5_sign(sign_string)
      Digest::MD5.hexdigest(sign_string).upcase
    end

    def mp_sign(sign_string)
      sign_string << "&key=#{WxpaySetting["app"]["pay_api_key"]}"
      md5_sign(sign_string)
    end

    def package_sign(sign_string)
      sign_string << "&key=#{WxpaySetting["app"]["partner_key"]}"
      md5_sign(sign_string)
    end

    def sha1_sign(sign_string)
      Digest::SHA1.hexdigest(sign_string)
    end

    def signature_sign(sign_string)
      sha1_sign(sign_string)
    end
  end
end
