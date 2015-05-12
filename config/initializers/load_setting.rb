UpyunSetting = YAML.load_file(File.join "#{Rails.root}", "config", "upyun.yml")[Rails.env || "development"]

WxpaySetting = YAML.load_file(File.join "#{Rails.root}", "config", "wxpay.yml")[Rails.env || "development"]