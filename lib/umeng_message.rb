# coding: utf-8
require 'digest'
require 'httpi'
require 'json'

module UmengMessage
  def get_appkey(platform)
    if platform == 'ios'
      UmengMessageSetting["ios_appkey"]
    else
      UmengMessageSetting["android_appkey"]
    end
  end

  def get_app_master_secret(platform)
    if platform == 'ios'
      UmengMessageSetting["ios_app_master_secret"]
    else
      UmengMessageSetting["android_app_master_secret"]
    end
  end

  #生成签名
  def generate_sign(platform, url, post_body)
   Digest::MD5.hexdigest('POST' + url + post_body + get_app_master_secret(platform))
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

  def check_status(platform, task_id)
    option = {
      appkey: get_appkey(platform),
      timestamp: Time.now.to_i.to_s,
      task_id: task_id
    }
    status_url = UmengMessageSetting["umeng_status_url"]
    post_body = string_convert_ascii(option.to_json)
    httpi_send(platform, status_url, post_body)
  end

  def httpi_send(platform, url, post_body)
    sign = generate_sign(platform, url, post_body)
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
    Rails.logger.debug "****************---send: #{response.body}"
    response
  end

  def send_message(platform, targets, ticker, title, text)
    option = {
      appkey: get_appkey(platform),
      timestamp: Time.now.to_i.to_s,
      content: targets
    }
    post_body = string_convert_ascii(option.to_json)
    upload_url = UmengMessageSetting["umeng_upload_url"]
    response = httpi_send(platform, upload_url, post_body)
    if response.code == 200
      file_id = response.raw_body[36..55]
    else
      Rails.logger.debug "****************error: #{response.body}"
      return false
    end

    base_params = {
      appkey: get_appkey(platform),
      timestamp: Time.now.to_i.to_s,
      type: 'customizedcast',
      alias_type: 'mobile',
      file_id: file_id,
      description: title
    }

    if platform == 'ios'
      ios_payload = {
        payload: {
          aps: {
            alert: text
          }
        }
      }
      base_params.merge!(ios_payload)
    else
      android_payload = {
        payload: {
          display_type: "notification",
          body: {
            ticker: ticker,
            title: title,
            text: text,
            after_open: "go_activity",
            activity: "us.bestapp.hoishow.ui.me.MessagesActivity"
          }
        }
      }
      base_params.merge!(android_payload)
    end
    send_url = UmengMessageSetting["umeng_send_url"]
    post_body = string_convert_ascii(base_params.to_json)
    Rails.logger.debug "****************send: #{post_body}"
    httpi_send(platform, send_url, post_body)
  end

  def push(targets, ticker, title, text)
    %w(ios android).each{|platform| send_message(platform, targets, ticker, title, text)}
  end
end
