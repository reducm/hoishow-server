# coding: utf-8
module Alipay
  module Openhome
    module Menu
      def self.create_menu(button)
        button ||= {"button"=> [ 
          { "actionParam"=> alipublic_root_url, "actionType"=> "link", "name"=> "选座购票", "authType"=> "loginAuth" }, 
          { "actionParam"=> alipublic_orders_url, "actionType"=> "link", "name"=> "我的订单", "authType"=> "loginAuth" } 
        ] }
        params = {
          method: "alipay.mobile.public.menu.add",
          biz_content: button.to_json,
        }
        get_data(params)
      end

      def self.update_menu(button)
        params = {
          method: "alipay.mobile.public.menu.update",
          biz_content: button.to_json,
        }
        get_data(params)
      end

      def self.search_menu
        params = {
          method: "alipay.mobile.public.menu.get"
        }
        get_data(params)
      end

      def self.get_data(options)
        options = {
          app_id: AlipaySetting["mobile_app_id"],
          sign_type: "RSA",
          timestamp: Alipay::Utils.timestamp,
          charset: "UTF8"
        }.merge(options)
        options.merge!(sign: Alipay::Sign.rsa_sign(
          Alipay::Utils.hash_sort_to_string(options), Alipay::Sign.pri_key_file)
        )
        request_url = "#{AlipaySetting["api_url"]}?#{options.to_query}"
        response = RestClient.post(request_url, nil)
        #wp_print "response: #{response}, sign_str: #{options[:sign]}, params: #{options.to_query}"
        response
      end
    end
  end
end
