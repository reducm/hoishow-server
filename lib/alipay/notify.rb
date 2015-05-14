# coding: utf-8
module Alipay
  module Notify
    def self.verify?(options)
      Sign.md5_verify?(options, AlipaySetting["PC_md5_key"]) 
    end

    def self.wireless_refund_verify?(options)
      Sign.md5_verify?(options, AlipaySetting["md5_key"]) 
    end

    def self.wap_verify?(options)
      Sign.wap_md5_verify(options)
    end

    def self.app_verity?(options)
     sign = options.delete("sign")
     sign_type = options["sec_id"] || options.delete("sign_type")
     Sign.rsa_verify?(Alipay::Utils.hash_sort_to_string(options), sign, AlipaySetting["alipay_rsa_pub_key"])
    end

    def self.verify_notify_id?(notify_id)
      options = {
        service: "notify_verify",
        partner: AlipaySetting["pid"],
        notify_id: notify_id
      }
      response_xml = RestClient.get "#{AlipaySetting["api_url"]}?#{options.to_query}"
      response_hash = Hash.from_xml(response_xml)
      response_hash["alipay"]["is_success"] == "T"
    end
  end
end
