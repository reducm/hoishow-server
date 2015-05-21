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

  def check_status(task_id = "uc50221143203989777000")
    appkey = UmengMessageSetting["umeng_app_key"] 
    time_stamp = Time.now.to_i.to_s
    option = {
      appkey: appkey,
      timestamp: time_stamp,
      task_id: task_id
    }
    status_url = UmengMessageSetting["umeng_status_url"]
    post_body = string_convert_ascii( option.to_json )
    response = httpi_send(status_url, post_body)
  end


  def httpi_send(url, post_body)
    sign = generate_sign("POST", url, post_body, UmengMessageSetting["umeng_app_master_secret"])
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
      return "httpi_send  fail"
    end
  end
#18633038302\n15626463079\n13929555038\n14718070850\n
  def android_send_message(content, notification_text, title, text)
    #############upload_file
    time_stamp = ( Time.now + 1.minutes ).to_i.to_s
    appkey = UmengMessageSetting["umeng_app_key"] 
    option = {
      appkey: appkey,
      timestamp: time_stamp,
      content: content
    }
    post_body = string_convert_ascii( option.to_json )
    upload_url = UmengMessageSetting["umeng_upload_url"]
    response = httpi_send(upload_url, post_body)
    if response.code == 200
      file_id = response.raw_body[36..55]
    else
      puts "upload_file fail"
      return false
    end
    #puts "file_id : #{file_id}"
############send_message_with_file_id
    option = {
      appkey: appkey,
      timestamp: time_stamp,
      type: "customizedcast",
      file_id: file_id,
      alias_type: "mobile",
      payload: {
        display_type: "notification",
        body: {
          ticker: notification_text, 
          title: title,
          text: text,
          after_open:"go_activity",
          activity: "us.bestapp.hoishow.ui.me.MessagesActivity"
        }
      }
    }
    send_url = UmengMessageSetting["umeng_send_url"]
    post_body = string_convert_ascii( option.to_json )
    response = httpi_send(send_url, post_body)
    if response.code == 200
      task_id = response.raw_body[36..57]
    else
      puts "send_message_with_file_id  fail"
      return false
    end
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
          after_open:"go_activity",
          activity: "us.bestapp.hoishow.ui.me.MessagesActivity"
        }
      }
    }
    send_url = UmengMessageSetting["umeng_send_url"]
    post_body = string_convert_ascii( option.to_json )
    method = "POST"
    sign = generate_sign(method, send_url, post_body, app_master_secret)
    request = HTTPI::Request.new
    request.open_timeout = 5 # seconds
    request.read_timeout = 5 # seconds
    request.url = send_url
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

  def upload_file
    appkey = UmengMessageSetting["umeng_app_key"] 
    time_stamp = Time.now.to_i.to_s
    app_master_secret = UmengMessageSetting["umeng_app_master_secret"] 
    content = "18633038302\n"
    option = {
      appkey: appkey,
      timestamp: time_stamp,
      content: content
    }
    upload_url = UmengMessageSetting["umeng_upload_url"]
    post_body = string_convert_ascii( option.to_json )
    method = "POST"
    sign = generate_sign(method, upload_url, post_body, app_master_secret)
    request = HTTPI::Request.new
    request.open_timeout = 5 # seconds
    request.read_timeout = 5 # seconds
    request.url = upload_url
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

  def send_message_with_file_id(title = "hoishow_test", text = "test_text")
    appkey = UmengMessageSetting["umeng_app_key"] 
    time_stamp = Time.now.to_i.to_s
    app_master_secret = UmengMessageSetting["umeng_app_master_secret"] 
    file_id = "PF959811432036847059"
    #file_id = "PF816131432039838350"
    option = {
      appkey: appkey,
      timestamp: time_stamp,
      type: "customizedcast",
      file_id: file_id,
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
    send_url = UmengMessageSetting["umeng_send_url"]
    post_body = string_convert_ascii( option.to_json )
    method = "POST"
    sign = generate_sign(method, send_url, post_body, app_master_secret)
    request = HTTPI::Request.new
    request.open_timeout = 5 # seconds
    request.read_timeout = 5 # seconds
    request.url = send_url
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
