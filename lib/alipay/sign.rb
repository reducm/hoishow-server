# coding: utf-8
require 'openssl'
require 'base64'
module Alipay
  module Sign
    SORTED_VERIFY_PARAMS = %w( service v sec_id notify_data  )
    def self.md5_sign(options, key)
      sign_string = Alipay::Utils.hash_sort_to_string(options)
      Digest::MD5.hexdigest("#{sign_string}#{key}")
    end

    def self.md5_verify?(options, key)
      sign = options.delete("sign")
      sign_type = options["sec_id"] || options.delete("sign_type")
      sign == md5_sign(options, key || AlipaySetting["PC_md5_key"])
    end

    def self.wap_md5_verify(options)
      options.delete("sign_type")
      sign = options.delete("sign")
      if options["sec_id"]
        sign_string = SORTED_VERIFY_PARAMS.map do |key|
          "#{key}=#{options[key]}"
        end.join("&")
      else
        options_array = options.to_a
        sign_string = options_array.map{|k,v| "#{k}=#{v}"}.join("&")
      end
      sign == Digest::MD5.hexdigest("#{sign_string}#{AlipaySetting["md5_key"]}")
    end

    # AlipaySetting["rsa_pri_key"]
    def self.rsa_sign(for_sign_string, key)
      openssl_key = OpenSSL::PKey::RSA.new(key)
      digest = OpenSSL::Digest::SHA1.new
      signature = openssl_key.sign digest, for_sign_string
      Base64.encode64(signature)
    end

    # AlipaySetting["alipay_rsa_pub_key"]
    def self.rsa_verify?(for_sign_string, signed_string, key)
      key = key.is_a?(String) ? Base64.decode64(key) : key
      openssl_public = OpenSSL::PKey::RSA.new(key)
      digest = OpenSSL::Digest::SHA1.new
      openssl_public.verify(digest, Base64.decode64(signed_string), for_sign_string)
    end

    def self.pri_key_file
      File.read("#{Rails.root}/config/certs/rsa_private_key.pem")
    end

    def self.pub_key_file
      File.open("#{Rails.root}/config/certs/alipay_public_key.pem")
    end

    def self.pri_app_key_file
      File.read("#{Rails.root}/config/certs/app_private_key.pem")
    end
  end
end
