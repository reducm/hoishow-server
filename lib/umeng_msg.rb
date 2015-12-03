# coding: utf-8
require 'umeng_msg/logger'
require 'umeng_msg/params'
require 'umeng_msg/sign'
require 'umeng_msg/service'
require 'umeng_msg/result'

module UmengMsg

  def self.appkey(platform)
    if platform == 'ios'
      UmengMessageSetting["ios_appkey"]
    else
      UmengMessageSetting["android_appkey"]
    end
  end

  def self.app_master_secret(platform)
    if platform == 'ios'
      UmengMessageSetting["ios_app_master_secret"]
    else
      UmengMessageSetting["android_app_master_secret"]
    end
  end

end
