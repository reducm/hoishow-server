UpyunSetting = YAML.load_file(File.join "#{Rails.root}", "config", "upyun.yml")[Rails.env || "development"]

ViagogoSetting = YAML.load_file(File.join "#{Rails.root}", "config", "viagogo.yml")[Rails.env || "development"]

MLBSetting = YAML.load_file(File.join "#{Rails.root}", "config", "mlb_translate.yml")[Rails.env || "development"]

AlipaySetting = YAML.load_file(File.join "#{Rails.root}", "config", "settings", "alipay.yml")

UmengMessageSetting = YAML.load_file(File.join "#{Rails.root}", "config", "umeng_message.yml")[Rails.env || "development"]

BikeSetting = YAML.load_file(File.join "#{Rails.root}", "config", "danche.yml")[Rails.env || "development"]

YongleSetting = YAML.load_file(File.join "#{Rails.root}", "config", "yongle.yml")[Rails.env || "development"]

ChinaSMS.use :luosimao, username: 'api', password: 'key-ba9012f30f24c9cee1e0377b83462f52'
