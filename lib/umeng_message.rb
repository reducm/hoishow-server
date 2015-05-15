# coding: utf-8
require 'digest'
require 'httpi'
require 'json'

module UmengMessage

  #生成签名
  def generate_sign(method, url, post_body, app_master_secret)
    Digest::MD5.hexdigest([method, url, post_body, app_master_secret].join)
  end

  #内容有中文的时候要用这个
  def string_convert_ascii(str)
    ascii = ""
    length = str.size 
    for i in 0...length do
      s = str[i]
      if !s.blank?
        code = s.ord
        if(code > 127)
          char_ascii = code.to_s(16)
          s = "0000"
          char_ascii = s[char_ascii.size, 4] + char_ascii
          ascii += "\\u" + char_ascii
        else
          ascii += str[i]
        end
      end
    end
    ascii
  end

      #alias: "18633038302, 13538945670",
      #alias: "13929555038, 17243576689",
  #TODO alias_str
  def send_message(alias_str = "18633038302,", title = "hoishow_test", text = "test_text")
    appkey = UmengMessageSetting["umeng_app_key"] 
    time_stamp = Time.now.to_i.to_s
    app_master_secret = UmengMessageSetting["umeng_app_master_secret"] 
    option = {
      appkey: appkey,
      timestamp: time_stamp,
      type: "customizedcast",
      alias: alias_str,
      alias_type: "mobile",
      payload: {
        display_type: "notification",
        body: {
          ticker:"推送测试", 
          title: title,
          text: text,
          after_open:"go_app"
        }
      }
    }
    url = UmengMessageSetting["umeng_url"]
    post_body = string_convert_ascii( option.to_json )
    method = "POST"
    sign = generate_sign(method, url, post_body, app_master_secret)
    request = HTTPI::Request.new
    request.open_timeout = 5 # seconds
    request.read_timeout = 5 # seconds
    request.url = url
    request.headers["Accept-Charset"] = "utf-8"
    request.headers["Content-type"] = "application/json"
    request.headers["Content-Length"] = post_body.size.to_s
    request.query = "sign=" + sign
    request.body = post_body
    begin
      response = HTTPI.post(request)
    rescue Exception => e
      e.response
      return false
    end
  end
end
