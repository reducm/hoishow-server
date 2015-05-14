# coding: utf-8
module Alipay
  module Utils
    def self.hash_sort_to_string(options)
      options.sort.map{|k,v| "#{k}=#{v}"}.join("&")
    end

    def self.app_hash_to_string(options = {})
      options.map{|k,v| "#{k}=#{["body", "subject"].include?(k.to_s) ? '"' << v << '"' : v.to_json}"}.join("&")
    end

    def self.generate_batch_no
      t = Time.now
      batch_no = t.strftime('%Y%m%d%H%M%S') + t.nsec.to_s
      batch_no.ljust(24, Random.new.rand(1..9).to_s)
    end
    
    def self.timestamp
      Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
