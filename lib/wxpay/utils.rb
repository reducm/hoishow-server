# coding: utf-8
module Wxpay
  module Utils
    extend self

    def package(options = {})
      sign_value = Wxpay::Sign.package_sign(opts_to_string(options))
      urlencode_opts_value(options) << "&sign=#{sign_value}"
    end

    def opts_to_string(options = {})
      options.sort.map{ |k, v| "#{k}=#{v}" }.join("&")
    end

    def opts_key_down_case_string(options = {})
      options.sort.map{ |k, v| "#{k.downcase}=#{v}" }.join("&")
    end

    def urlencode_opts_value(options = {})
      options.sort.map{ |k, v| "#{k}=#{CGI.escape(v)}" }.join("&")
    end

    def noncestr
      SecureRandom.urlsafe_base64(16)
    end

    def timestamp
      Time.now.to_i.to_s
    end

    def normal_build_xml(hash, is_cdata = true)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.xml do
          hash.each do |k,v|
            xml.send(k, v)
          end
        end
      end
      result = builder.to_xml
    end
  end
end
