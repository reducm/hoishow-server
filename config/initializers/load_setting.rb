UpyunSetting = YAML.load_file(File.join "#{Rails.root}", "config", "upyun.yml")[Rails.env || "development"]

AlipaySetting = YAML.load_file(File.join "#{Rails.root}", "config", "alipay.yml")[Rails.env || "development"]

WxpaySetting = YAML.load_file(File.join "#{Rails.root}", "config", "wxpay.yml")[Rails.env || "development"]

UmengMessageSetting = YAML.load_file(File.join "#{Rails.root}", "config", "umeng_message.yml")[Rails.env || "development"]
